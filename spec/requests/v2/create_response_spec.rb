# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Create Response Request', type: :request do
  describe 'POST /api/v2/respondents/build_response' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    shared_context 'with staging folder visibility' do
      def force_export_now
        ClaimsExportJob.perform_now
      end

      def formatted_name_for_filename(text)
        text.parameterize(separator: '_', preserve_case: true)
      end

      before do
        stub_request(:any, /mocked_atos_server\.com/).to_rack(EtAtosFileTransfer::Engine)
      end

      let(:staging_folder) do
        EtApi::Test::StagingFolder.new url: 'http://mocked_atos_server.com',
                                       username: Rails.configuration.et_atos_api.username,
                                       password: Rails.configuration.et_atos_api.password
      end

      let(:emails_sent) do
        EtApi::Test::EmailsSent.new
      end
    end

    shared_context 'with setup for any response' do |json_factory:|
      let(:input_factory) { json_factory.call }
      let(:input_response_factory) { input_factory.data.detect { |d| d.command == 'BuildResponse' }.data }
      let(:input_respondent_factory) { input_factory.data.detect { |d| d.command == 'BuildRespondent' }.data }
      let(:input_representative_factory) { input_factory.data.detect { |d| d.command == 'BuildRepresentative' }.try(:data) }
      let(:output_files_generated) { [] }

      def perform_action
        json_data = input_factory.to_json
        post '/api/v2/respondents/build_response', params: json_data, headers: default_headers
      end

      before do
        perform_action
      end
    end

    shared_context 'with transactions off for use with other processes' do
      around do |example|
        old = use_transactional_tests
        self.use_transactional_tests = false
        example.run
        self.use_transactional_tests = old
      end
    end

    shared_context 'with fake sidekiq' do
      around do |example|
        begin
          original_adapter = ActiveJob::Base.queue_adapter
          ActiveJob::Base.queue_adapter = :test
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
          ActiveJob::Base.queue_adapter.performed_jobs.clear
          example.run
        ensure
          ActiveJob::Base.queue_adapter = original_adapter
        end
      end

      def run_background_jobs
        previous_value = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        ActiveJob::Base.queue_adapter.enqueued_jobs.select { |j| j[:job] == EventJob }.each do |job|
          job[:job].perform_now(*ActiveJob::Arguments.deserialize(job[:args]))
        end
      ensure
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = previous_value
      end
    end

    shared_context 'with background jobs running' do
      before do |example|
        next if example.metadata[:background_jobs] == :disable

        run_background_jobs
        sleep 0.1
        force_export_now
      end
    end

    shared_examples 'any response variation' do
      it 'responda with a 201 status', background_jobs: :disable do
        # Assert - Make sure we get a 201 - to say the commands have been accepted
        expect(response).to have_http_status(:accepted)
      end

      it 'returns the uuid as a reference to what will be created', background_jobs: :disable do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'accepted', uuid: input_factory.uuid
      end

      it 'returns the reference in the metadata for the response', background_jobs: :disable do
        # Assert - Make sure we get the reference in the metadata
        expect(json_response).to include meta: a_hash_including('BuildResponse' => a_hash_including(reference: instance_of(String)))
      end

      it 'returns the submitted_at in the metadata for the response', background_jobs: :disable do
        # Assert - Make sure we get the reference in the metadata
        expect(json_response).to include meta: a_hash_including('BuildResponse' => a_hash_including(submitted_at: instance_of(String)))
      end

      it 'returns the office address in the metadata for the response', background_jobs: :disable do
        # Assert - Make sure we get the reference in the metadata
        expect(json_response[:meta]).to include 'BuildResponse' => a_hash_including(
          office_address: 'Bristol Civil and Family Justice Centre, 2 Redcliff Street, Bristol, BS1 6GR'
        )
      end

      it 'returns the office phone number in the metadata for the response', background_jobs: :disable do
        # Assert - Make sure we get the reference in the metadata
        expect(json_response[:meta]).to include 'BuildResponse' => a_hash_including(
          office_phone_number: '0117 929 8261'
        )
      end

      it 'returns the expected pdf url which will return 404 when fetched before background jobs run', background_jobs: :disable do
        # Assert - Make sure we get the pdf url in the metadata and it returns a 404 when accessed
        url = json_response.dig(:meta, 'BuildResponse', 'pdf_url')
        res = HTTParty.get(url)
        expect(res.code).to be 404
      end

      it 'returns the actual pdf url which should be accessible after the background jobs have run' do
        # Assert - Make sure we get the pdf url in the metadata and it returns a 404 when accessed
        url = json_response.dig(:meta, 'BuildResponse', 'pdf_url')
        res = HTTParty.get(url)
        expect(res.code).to be 200
      end

      it 'creates a valid txt file in the correct place in the landing folder' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        respondent_name = input_respondent_factory.name
        output_filename_txt = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.txt"
        expect(staging_folder.et3_txt_file(output_filename_txt)).to have_correct_file_structure(errors: errors)
      end

      it 'creates a valid txt file with correct header data' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        respondent_name = input_respondent_factory.name
        output_filename_txt = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.txt"
        expect(staging_folder.et3_txt_file(output_filename_txt)).to have_correct_contents_for(
          response: input_response_factory,
          respondent: input_respondent_factory,
          representative: input_representative_factory,
          errors: errors
        ), -> { errors.join("\n") }
      end

      it 'creates a valid pdf file the data filled in correctly' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        respondent_name = input_respondent_factory.name
        output_filename_pdf = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.pdf"
        expect(staging_folder.et3_pdf_file(output_filename_pdf)).to have_correct_contents_for(
          response: input_response_factory,
          respondent: input_respondent_factory,
          representative: input_representative_factory,
          errors: errors
        ), -> { errors.join("\n") }
      end
    end

    shared_examples 'any bad request error variation' do
      it 'responds with a 400 status', background_jobs: :disable do
        # Assert - Make sure we get a 400 - to say the commands have not been accepted
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the status  as not accepted', background_jobs: :disable do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'not_accepted', uuid: input_factory.uuid
      end
    end

    shared_examples 'email validation' do
      it 'sends an HTML email to the respondent with the pdf attached' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        email_sent = emails_sent.new_response_html_email_for(reference: reference)
        expect(email_sent).to have_correct_content_for(input_response_factory, reference: reference)
      end

      it 'sends a plain text email to the respondent with the pdf attached' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        email_sent = emails_sent.new_response_text_email_for(reference: reference)
        expect(email_sent).to have_correct_content_for(input_response_factory, reference: reference)
      end
    end

    include_context 'with staging folder visibility'

    # Important note.  There is no validation right now so if we do a response to a non existent claim all is good
    # this MIGHT change - currently unsure what the validation requirement is for this.  There is talk of there being
    # no knowledge of ET1 data from ET3 side of things - but will be questioned.
    context 'with json for a response with representative to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
        json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_representative) }
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'email validation'
    end

    context 'with json for a response (minimum data) with representative (minimum data) to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
        json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_representative_minimal) }
      include_context 'with background jobs running'
      include_examples 'any response variation'
    end

    context 'with json for a response without representative to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
        json_factory: -> { FactoryBot.build(:json_build_response_commands, :without_representative) }
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'email validation'
    end

    context 'with json for a response with an rtf upload' do
      rtf_file_path = Rails.root.join('spec', 'fixtures', 'example.rtf').to_s
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
        json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_rtf, rtf_file_path: rtf_file_path) }
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'email validation'

      it 'includes the rtf file in the staging folder' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        respondent_name = input_respondent_factory.name
        output_filename_rtf = "#{reference}_ET3_Attachment_#{respondent_name}.rtf"
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, output_filename_rtf)
          staging_folder.extract(output_filename_rtf, to: full_path)
          expect(full_path).to be_a_file_copy_of(rtf_file_path)
        end
      end
      it 'marks the pdf as having an rtf file attached'
    end

    context 'with json for a response with an invalid office code in the case number' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
        json_factory: -> { FactoryBot.build(:json_build_response_commands, :invalid_case_number) }
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'
      it 'has the correct error in the case_number field' do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildResponse' }.uuid
        expect(json_response.dig(:errors).map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                           code: "invalid_office_code",
                                                                                           title: "Invalid case number",
                                                                                           detail: "Invalid case number",
                                                                                           source: "/data/0/case_number",
                                                                                           command: "BuildResponse",
                                                                                           uuid: expected_uuid
      end
    end
  end
end
