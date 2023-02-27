# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Repair Response Request', type: :request do
  describe 'POST /api/v2/respondents/repair_response' do
    include_context 'with local storage'
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
        EtAtosExport::ClaimsExportJob.perform_now
      end

      def formatted_name_for_filename(text)
        text.parameterize(separator: '_', preserve_case: true)
      end

      before do
        stub_request(:any, /mocked_atos_server\.com/).to_rack(EtAtosFileTransfer::Engine)
      end

      let(:staging_folder) do
        EtApi::Test::StagingFolder.new url: 'http://mocked_atos_server.com',
                                       username: 'atos',
                                       password: 'password'
      end

      let(:secondary_staging_folder) do
        EtApi::Test::StagingFolder.new url: 'http://mocked_atos_server.com',
                                       username: 'atos2',
                                       password: 'password'
      end

      let(:emails_sent) do
        EtApi::Test::EmailsSent.new
      end
    end

    shared_context 'with setup for any response' do
      let(:input_response_factory) { input_factory.data.detect { |d| d.command == 'BuildResponse' }.data }
      let(:input_respondent_factory) { input_factory.data.detect { |d| d.command == 'BuildRespondent' }.data }
      let(:input_representative_factory) { input_factory.data.detect { |d| d.command == 'BuildRepresentative' }.try(:data) }
      let(:output_files_generated) { [] }
      let(:input_json) { build(:json_repair_response_command, response_id: response_to_repair.id).as_json }
      let(:input_response_attributes) { response_to_repair.attributes.to_h.with_indifferent_access }
      let(:input_respondent_attributes) do
        build :json_respondent_data,
              address_attributes: build(:json_address_data, response_to_repair.respondent.address.attributes),
              **response_to_repair.respondent.attributes.symbolize_keys
      end
      let(:input_representative_attributes) do
        if response_to_repair.representative.present?
          build :json_respondent_data,
                address_attributes: build(:json_address_data, response_to_repair.representative.address.attributes),
                **response_to_repair.representative.attributes.symbolize_keys
        else
          {}
        end
      end

      def perform_action
        post '/api/v2/respondents/repair_response', params: input_json.to_json, headers: default_headers
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
          prepare_local_active_storage
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
        force_export_now
      end
    end

    shared_examples 'any response variation' do
      it 'responds with a 201 status', background_jobs: :disable do
        # Assert - Make sure we get a 201 - to say the commands have been accepted
        expect(response).to have_http_status(:accepted)
      end

      it 'returns status of accepted', background_jobs: :disable do
        expect(json_response).to include status: 'accepted'
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

    shared_examples 'a response exported to primary ATOS' do |exclude_contents: false|
      it 'creates a valid txt file in the correct place in the landing folder' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name
        output_filename_txt = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.txt"
        expect(staging_folder.et3_txt_file(output_filename_txt)).to have_correct_file_structure(errors: errors)
      end

      it 'creates a valid txt file with correct header data' do
        next if exclude_contents

        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name
        output_filename_txt = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.txt"
        expect(staging_folder.et3_txt_file(output_filename_txt)).to have_correct_contents_for(
          response: input_response_attributes,
          respondent: input_respondent_attributes,
          representative: input_representative_attributes,
          errors: errors
        ), -> { errors.join("\n") }
      end

      it 'creates a valid pdf file the data filled in correctly' do
        next if exclude_contents

        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name
        output_filename_pdf = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.pdf"
        expect(staging_folder.et3_pdf_file(output_filename_pdf, template: response_to_repair.pdf_template_reference)).to have_correct_contents_for(
          response: input_response_attributes,
          respondent: input_respondent_attributes,
          representative: input_representative_attributes,
          errors: errors
        ), -> { errors.join("\n") }
      end
    end

    shared_examples 'a response exported to secondary ATOS' do
      it 'creates a valid txt file in the correct place in the landing folder' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name
        output_filename_txt = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.txt"
        expect(secondary_staging_folder.et3_txt_file(output_filename_txt)).to have_correct_file_structure(errors: errors)
      end

      it 'creates a valid txt file with correct header data' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name
        output_filename_txt = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.txt"
        expect(secondary_staging_folder.et3_txt_file(output_filename_txt)).to have_correct_contents_for(
          response: input_response_attributes,
          respondent: input_respondent_attributes,
          representative: input_representative_attributes,
          errors: errors
        ), -> { errors.join("\n") }
      end

      it 'creates a valid pdf file the data filled in correctly' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name
        output_filename_pdf = "#{reference}_ET3_#{formatted_name_for_filename(respondent_name)}.pdf"
        expect(secondary_staging_folder.et3_pdf_file(output_filename_pdf, template: response_to_repair.pdf_template_reference)).to have_correct_contents_for(
          response: input_response_attributes,
          respondent: input_respondent_attributes,
          representative: input_representative_attributes,
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

    include_context 'with staging folder visibility'

    context 'with json for a response with just a respondent' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to primary ATOS'
      let(:response_to_repair) { create(:response, :broken_with_files_missing, :with_command) }
    end

    context 'with json for a response with a respondent and a representative' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to primary ATOS'
      let(:response_to_repair) { create(:response, :broken_with_files_missing, :with_command, :with_representative) }
    end

    context 'with json for a response with an rtf upload that has not yet been processed' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      rtf_file_path = Rails.root.join('spec', 'fixtures', 'example.rtf').to_s
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      let(:response_to_repair) { create(:response, :with_command, additional_information_key: additional_information_key) }
      it 'includes the rtf file in the staging folder' do
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name.gsub(/ /, '_')
        output_filename_rtf = "#{reference}_ET3_Attachment_#{respondent_name}.rtf"
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, output_filename_rtf)
          staging_folder.extract(output_filename_rtf, to: full_path)
          expect(full_path).to be_a_file_copy_of(rtf_file_path)
        end
      end
    end

    context 'with json for a response with an rtf upload that has been processed but file has been lost' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      rtf_file_path = Rails.root.join('spec', 'fixtures', 'example.rtf').to_s
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      let(:uploaded_file) do
        create(:uploaded_file, :example_response_input_rtf, :user_file_scope).tap do |uploaded_file|
          uploaded_file.file.blob.delete
        end
      end
      let(:response_to_repair) { create(:response, :with_command, additional_information_key: additional_information_key, uploaded_files: [uploaded_file]) }
      it 'includes the rtf file in the staging folder' do
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name.gsub(/ /, '_')
        output_filename_rtf = "#{reference}_ET3_Attachment_#{respondent_name}.rtf"
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, output_filename_rtf)
          staging_folder.extract(output_filename_rtf, to: full_path)
          expect(full_path).to be_a_file_copy_of(rtf_file_path)
        end
      end
    end

    context 'with json for a response with an rtf upload that has been processed but attachment is not present' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      rtf_file_path = Rails.root.join('spec', 'fixtures', 'example.rtf').to_s
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      let(:uploaded_file) do
        create(:uploaded_file,:example_response_input_rtf, :user_file_scope).tap do |uploaded_file|
          uploaded_file.file.attachment.delete
        end
      end
      let(:response_to_repair) { create(:response, :with_command, additional_information_key: additional_information_key, uploaded_files: [uploaded_file]) }
      it 'includes the rtf file in the staging folder' do
        reference = response_to_repair.reference
        respondent_name = response_to_repair.respondent.name.gsub(/ /, '_')
        output_filename_rtf = "#{reference}_ET3_Attachment_#{respondent_name}.rtf"
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, output_filename_rtf)
          staging_folder.extract(output_filename_rtf, to: full_path)
          expect(full_path).to be_a_file_copy_of(rtf_file_path)
        end
      end
    end

    context 'with json for a response with an rtf upload that has been processed successfully' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      rtf_file_path = Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf').to_s
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      let(:uploaded_files) do
        [
          build(:uploaded_file, :upload_to_blob, :example_response_input_rtf, :user_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_rtf, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_text, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_pdf, :system_file_scope)
        ]
      end
      let(:respondent_name) { 'Fred Bloggs' }
      let(:response_to_repair) do
        create :response,
               :with_command,
               additional_information_key: additional_information_key,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name)
      end
      it 'includes the rtf file in the staging folder' do
        reference = response_to_repair.reference
        output_filename_rtf = "#{reference}_ET3_Attachment_#{respondent_name.gsub(/ /, '_')}.rtf"
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, output_filename_rtf)
          staging_folder.extract(output_filename_rtf, to: full_path)
          expect(full_path).to be_a_file_copy_of(rtf_file_path)
        end
      end
    end
    context 'with json for a response with a pdf file that had been processed but lost' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to primary ATOS', exclude_contents: true

      let(:uploaded_files) do
        [
          create(:uploaded_file, :upload_to_blob, :example_response_text, :system_file_scope),
          create(:uploaded_file, :upload_to_blob, :example_response_pdf, :system_file_scope).tap do |uploaded_file|
            uploaded_file.file.blob.delete
          end
        ]
      end
      let(:respondent_name) { 'Fred Bloggs' }
      let(:response_to_repair) do
        create :response,
               :with_command,
               additional_information_key: nil,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name)
      end
    end

    context 'with json for a response that had been processed but its output txt file lost' do
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to primary ATOS', exclude_contents: true

      let(:uploaded_files) do
        [
          create(:uploaded_file, :upload_to_blob, :example_response_text, :system_file_scope).tap do |uploaded_file|
            uploaded_file.file.blob.delete
          end,
          create(:uploaded_file, :upload_to_blob, :example_response_pdf, :system_file_scope)
        ]
      end
      let(:respondent_name) { 'Fred Bloggs' }
      let(:response_to_repair) do
        create :response,
               :with_command,
               additional_information_key: nil,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name)
      end
    end
    context 'with json for a response that had been processed but its output rtf file lost' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      rtf_file_path = Rails.root.join('spec', 'fixtures', 'example.rtf').to_s
      before do
        response_to_repair.uploaded_files.find_by(filename: 'et3_atos_export.rtf').file.blob.delete
      end
      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      let(:uploaded_files) do
        [
          build(:uploaded_file, :upload_to_blob, :example_response_input_rtf, :user_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_rtf, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_text, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_pdf, :system_file_scope)
        ]
      end
      let(:respondent_name) { 'Fred Bloggs' }
      let(:response_to_repair) do
        create :response,
               :with_command,
               additional_information_key: additional_information_key,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name)
      end

      it 'includes the rtf file in the staging folder' do
        reference = response_to_repair.reference
        output_filename_rtf = "#{reference}_ET3_Attachment_#{respondent_name.gsub(/ /, '_')}.rtf"
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, output_filename_rtf)
          staging_folder.extract(output_filename_rtf, to: full_path)
          expect(full_path).to be_a_file_copy_of(rtf_file_path)
        end
      end

    end
  end
end
