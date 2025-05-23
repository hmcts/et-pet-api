# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Create Response Request', js: false, type: :request do
  describe 'POST /api/v2/respondents/build_response' do
    include_context 'with local storage'

    let(:default_headers) do
      {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }
    let(:emails_sent) do
      EtApi::Test::EmailsSent.new
    end

    shared_context 'with setup for any response' do |json_factory:|
      let(:input_factory) { json_factory.call }
      let(:input_response_factory) { input_factory.data.detect { |d| d.command == 'BuildResponse' }.data }
      let(:input_respondent_factory) { input_factory.data.detect { |d| d.command == 'BuildRespondent' }.data }
      let(:input_representative_factory) { input_factory.data.detect { |d| d.command == 'BuildRepresentative' }.try(:data) }
      let(:output_files_generated) { [] }
      # @return [EtApi::Test::EtExporter] The exporter class to use for testing
      let(:et_exporter) { EtApi::Test::EtExporter }

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

        original_adapter = ActiveJob::Base.queue_adapter
        ActiveJob::Base.queue_adapter = :test
        ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        ActiveJob::Base.queue_adapter.performed_jobs.clear
        example.run
      ensure
        ActiveJob::Base.queue_adapter = original_adapter

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

      it 'returns the expected pdf url which will return 404 when fetched before background jobs run', background_jobs: :disable do
        # Assert - Make sure we get the pdf url in the metadata and it returns a 404 when accessed
        url = json_response.dig(:meta, 'BuildResponse', 'pdf_url')
        get(url)
        expect(response).to have_http_status :not_found
      end

      it 'returns the actual pdf url which should be accessible after the background jobs have run' do
        # Assert - Make sure we get the pdf url in the metadata and it returns a 404 when accessed
        url = json_response.dig(:meta, 'BuildResponse', 'pdf_url')
        get(url)
        expect(response).to have_http_status :ok
      end

      it 'returns identical data if called twice with the same uuid', background_jobs: :disable do
        # Arrange - get the response from the first call and reset the session ready for the second
        response1 = JSON.parse(response.body).with_indifferent_access
        reset!

        # Act - Call the endpoint for the second time
        perform_action
        response2 = JSON.parse(response.body).with_indifferent_access

        # Arrange - check they are identical
        expect(response1).to eq response2
      end

      it 'creates no more records if called a second time with same uuid', background_jobs: :disable do

        # Assert
        expect { perform_action }.not_to change(Response, :count)
      end
    end

    shared_examples 'a response exported to et_exporter' do
      it 'has the claim details in the payload' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        et_exporter.find_response_by_reference(reference).assert_response_details(input_response_factory)
      end

      it 'has the respondent in the payload' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        et_exporter.find_response_by_reference(reference).assert_respondent(input_respondent_factory)
      end

      it 'has the representative in the payload' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        et_exporter.find_response_by_reference(reference).assert_representative(input_representative_factory)
      end

      it 'creates a valid pdf file with the data filled in correctly' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        et_exporter.find_response_by_reference(reference).et3_pdf_file(template: input_response_factory.pdf_template_reference).assert_correct_contents_for(
          response: input_response_factory,
          respondent: input_respondent_factory,
          representative: input_representative_factory
        )
      end
    end

    shared_examples 'any bad request error variation' do
      it 'responds with a 400 status', background_jobs: :disable do
        # Assert - Make sure we get a 400 - to say the commands have not been accepted
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the status as not accepted', background_jobs: :disable do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'not_accepted', uuid: input_factory.uuid
      end
    end

    shared_context 'with office assignment from ccd for response email' do
      before do
        sidekiq_job_data = {}
        case_id = '1234567890'
        case_reference = json_response.dig(:meta, 'BuildResponse', :reference)
        case_type_id = 'doesntmatter'
        export = create(:export, :response, external_system: build(:external_system, reference: 'doesntmatter', name: 'doesntmatter'), resource: Response.find_by(reference: case_reference))
        data = {
          sidekiq: sidekiq_job_data.except('class', 'args', 'queue'),
          export_id: export.id,
          external_data: {
            case_id: case_id,
            case_reference: case_reference,
            case_type_id: case_type_id,

            office: office_for(case_number: case_reference).name
          },
          state: :complete,
          message: 'Response exported'
        }
        ResponseExportFeedbackReceivedHandler.new.handle(data.to_json)
      end
    end

    shared_examples 'email validation using standard template' do
      it 'sends an HTML email to the respondent with the pdf attached using the standard template' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        email_sent = emails_sent.new_response_html_email_for(reference: reference, template_reference: 'et3-v1-en')
        expect(email_sent).to have_correct_content_for(input_response_factory, reference: reference)
      end

      it 'sends a plain text email to the respondent with the pdf attached using the standard template' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        email_sent = emails_sent.new_response_text_email_for(reference: reference, template_reference: 'et3-v1-en')
        expect(email_sent).to have_correct_content_for(input_response_factory, reference: reference)
      end
    end

    shared_examples 'email validation using welsh template' do
      it 'sends an HTML email to the respondent with the pdf attached using the welsh template' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        email_sent = emails_sent.new_response_html_email_for(reference: reference, template_reference: 'et3-v1-cy')
        expect(email_sent).to have_correct_content_for(input_response_factory, reference: reference)
      end

      it 'sends a plain text email to the respondent with the pdf attached using the welsh template' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        email_sent = emails_sent.new_response_text_email_for(reference: reference, template_reference: 'et3-v1-cy')
        expect(email_sent).to have_correct_content_for(input_response_factory, reference: reference)
      end
    end

    # Important note.  There is no validation right now so if we do a response to a non existent claim all is good
    # this MIGHT change - currently unsure what the validation requirement is for this.  There is talk of there being
    # no knowledge of ET1 data from ET3 side of things - but will be questioned.
    context 'with json for a response with representative to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_representative) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with office assignment from ccd for response email'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
      include_examples 'email validation using standard template'
    end

    context 'with json for a response using welsh pdf and email templates with representative to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_representative, :with_welsh_pdf, :with_welsh_email) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with office assignment from ccd for response email'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
      include_examples 'email validation using welsh template'
    end

    context 'with json for a response (minimum data) with representative (minimum data) to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_representative_minimal) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
    end

    context 'with json for a response without representative to a non existent claim' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :without_representative) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with office assignment from ccd for response email'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
      include_examples 'email validation using standard template'
    end

    context 'with json for a response with representative to a non existent claim to be not exported as it is for the default office' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :for_default_office) } # rubocop:disable FactoryBot/SyntaxMethods

      include_context 'with office assignment from ccd for response email'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'email validation using standard template'
      it 'is not exported' do
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        et_exporter.assert_response_not_exported_by_reference(reference)
      end
    end

    context 'with json for a response with an additional_information file upload in local mode' do
      rtf_file_path = Rails.root.join("spec/fixtures/example.rtf").to_s
      include_context 'with local storage'
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :with_rtf, rtf_file_path: rtf_file_path) } # rubocop:disable FactoryBot/SyntaxMethods

      include_context 'with office assignment from ccd for response email'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
      include_examples 'email validation using standard template'
    end

    context 'with json for a response with an invalid office code in the case number' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, :invalid_case_number) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'
      it 'has the correct error in the case_number field' do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildResponse' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                       code: "invalid_office_code",
                                                                                       title: "Invalid case number",
                                                                                       detail: "Invalid case number",
                                                                                       source: "/data/0/case_number",
                                                                                       command: "BuildResponse",
                                                                                       uuid: expected_uuid
      end
    end

    context 'with json for a response with an invalid address in the representative data' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, representative_traits: [:full, :invalid_address_keys]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'
      it 'has the correct error in the address_attributes field' do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildRepresentative' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                       code: "invalid_address",
                                                                                       title: "Invalid address",
                                                                                       detail: "Invalid address",
                                                                                       source: "/data/2/address_attributes",
                                                                                       command: "BuildRepresentative",
                                                                                       uuid: expected_uuid
      end
    end

    context 'with json for a response with an invalid address in the respondent data' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, respondent_traits: [:full, :invalid_address_keys]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'
      it 'has the correct error in the address_attributes field' do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildRespondent' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                       code: "invalid_address",
                                                                                       title: "Invalid address",
                                                                                       detail: "Invalid address",
                                                                                       source: "/data/1/address_attributes",
                                                                                       command: "BuildRespondent",
                                                                                       uuid: expected_uuid
      end
    end

    context 'with json for a response with an invalid queried_hours attribute in the response data' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response',
                      json_factory: -> { FactoryBot.build(:json_build_response_commands, response_traits: [:full, :invalid_queried_hours]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'
      it 'has the correct error in the queried_hours field' do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildResponse' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                       code: "less_than_or_equal_to",
                                                                                       title: "must be less than or equal to 168.0",
                                                                                       detail: "must be less than or equal to 168.0",
                                                                                       source: "/data/0/queried_hours",
                                                                                       command: "BuildResponse",
                                                                                       uuid: expected_uuid
      end

    end
  end
end
