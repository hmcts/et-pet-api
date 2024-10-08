# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Repair Response Request', type: :request do
  describe 'POST /api/v2/respondents/repair_response' do
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

    shared_context 'with setup for any response' do
      # @!method et_exporter()
      # @return [Class<EtApi::Test::EtExporter>] The exporter class to use for testing
      # @type [Class<EtApi::Test::EtExporter>]
      let(:et_exporter) { EtApi::Test::EtExporter }

      let(:input_response_factory) { input_factory.data.detect { |d| d.command == 'BuildResponse' }.data }
      let(:input_respondent_factory) { input_factory.data.detect { |d| d.command == 'BuildRespondent' }.data }
      let(:input_representative_factory) { input_factory.data.detect { |d| d.command == 'BuildRepresentative' }.try(:data) }
      let(:output_files_generated) { [] }
      let(:input_json) { build(:json_repair_response_command, response_id: response_to_repair.id).as_json }
      let(:input_response_attributes) { response_to_repair.attributes.to_h.with_indifferent_access }
      let(:input_respondent_attributes) do
        build(:json_respondent_data,
              address_attributes: build(:json_address_data, response_to_repair.respondent.address.attributes.symbolize_keys.except(:string, :created_at, :updated_at, :country, :id)),
              work_address_attributes: build(:json_address_data, response_to_repair.respondent.work_address.attributes.symbolize_keys.except(:string, :created_at, :updated_at, :country, :id)),
              **response_to_repair.respondent.attributes.symbolize_keys)
      end
      let(:input_representative_attributes) do
        if response_to_repair.representative.present?
          build :json_respondent_data,
                address_attributes: build(:json_address_data, response_to_repair.representative.address.attributes.symbolize_keys.slice(:building, :street, :locality, :county, :post_code)),
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

    shared_examples 'a response exported to et_exporter' do |exclude_contents: false|
      it 'has the claim details in the payload' do
        reference = response_to_repair.reference
        et_exporter.find_response_by_reference(reference).assert_response_details(input_response_attributes.as_json.deep_symbolize_keys.slice(:reference))
      end

      it 'has the respondent in the payload' do
        reference = response_to_repair.reference
        et_exporter.find_response_by_reference(reference).assert_respondent(input_respondent_attributes.as_json.deep_symbolize_keys.slice(:name, :address_attributes, :work_address_attributes))
      end

      it 'has the representative in the payload' do
        reference = response_to_repair.reference
        et_exporter.find_response_by_reference(reference).assert_representative(input_representative_attributes.as_json.deep_symbolize_keys.slice(:name, :address_attributes))
      end

      it 'creates a valid pdf file with the data filled in correctly' do
        next if exclude_contents

        reference = response_to_repair.reference
        et_exporter.find_response_by_reference(reference).et3_pdf_file(template: response_to_repair.pdf_template_reference).assert_correct_contents_for(
          response: input_response_attributes,
          respondent: input_respondent_attributes,
          representative: input_representative_attributes
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

    context 'with json for a response with just a respondent' do
      let(:response_to_repair) { create(:response, :broken_with_files_missing, :with_command) }

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
    end

    context 'with json for a response with a respondent and a representative' do
      let(:response_to_repair) { create(:response, :broken_with_files_missing, :with_command, :with_representative) }

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
    end

    context 'with json for a response with an additional_information file upload that has not yet been processed' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      let(:response_to_repair) { create(:response, :with_command, additional_information_key: additional_information_key) }

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      it 'includes the additional information file in the exported data' do
        reference = response_to_repair.reference
        full_path = et_exporter.find_response_by_reference(reference).additional_information_file.path
        expect(full_path).to be_a_file_copy_of(Rails.root.join("spec/fixtures/example.rtf"))
      end
    end

    context 'with json for a response with an additional_information upload that has been processed but file has been lost' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      let(:uploaded_file) do
        create(:uploaded_file, :example_response_input_rtf, :user_file_scope).tap do |uploaded_file|
          uploaded_file.file.blob.delete
        end
      end
      let(:response_to_repair) { create(:response, :with_command, additional_information_key: additional_information_key, uploaded_files: [uploaded_file]) }

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      it 'includes the additional information file in the exported data' do
        reference = response_to_repair.reference
        full_path = et_exporter.find_response_by_reference(reference).additional_information_file.path
        expect(full_path).to be_a_file_copy_of(Rails.root.join("spec/fixtures/example.rtf"))
      end
    end

    context 'with json for a response with an additional_information file upload that has been processed but attachment is not present' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      let(:uploaded_file) do
        create(:uploaded_file, :example_response_input_rtf, :user_file_scope).tap do |uploaded_file|
          uploaded_file.file.attachment.delete
        end
      end
      let(:response_to_repair) { create(:response, :with_command, additional_information_key: additional_information_key, uploaded_files: [uploaded_file]) }

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      it 'includes the additional information file in the exported data' do
        reference = response_to_repair.reference
        full_path = et_exporter.find_response_by_reference(reference).additional_information_file.path
        expect(full_path).to be_a_file_copy_of(Rails.root.join("spec/fixtures/example.rtf"))
      end
    end

    context 'with json for a response with an additional_informatio file upload that has been processed successfully' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      let(:uploaded_files) do
        [
          build(:uploaded_file, :upload_to_blob, :example_response_input_rtf, :user_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_additional_information, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_text, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_pdf, :system_file_scope)
        ]
      end
      let(:respondent_name) { 'Fred Bloggs' }
      let(:response_to_repair) do
        create(:response,
               :with_command,
               additional_information_key: additional_information_key,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name))
      end

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      it 'includes the additional information file in the exported data' do
        reference = response_to_repair.reference
        full_path = et_exporter.find_response_by_reference(reference).additional_information_file.path
        expect(full_path).to be_a_file_copy_of(Rails.root.join("spec/fixtures/example.rtf"))
      end
    end

    context 'with json for a response with a pdf file that had been processed but lost' do
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
        create(:response,
               :with_command,
               additional_information_key: nil,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, :et3, name: respondent_name))
      end

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter'
    end

    context 'with json for a response that had been processed but its output txt file lost' do
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
        create(:response,
               :with_command,
               additional_information_key: nil,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name))
      end

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'
      include_examples 'a response exported to et_exporter', exclude_contents: true
    end

    context 'with json for a response that had been processed but its output pdf file lost' do
      let!(:additional_information_key) { build(:json_response_data, :with_rtf).additional_information_key }
      let(:uploaded_files) do
        [
          build(:uploaded_file, :upload_to_blob, :example_response_input_rtf, :user_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_additional_information, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_text, :system_file_scope),
          build(:uploaded_file, :upload_to_blob, :example_response_pdf, :system_file_scope)
        ]
      end
      let(:respondent_name) { 'Fred Bloggs' }
      let(:response_to_repair) do
        create(:response,
               :with_command,
               additional_information_key: additional_information_key,
               uploaded_files: uploaded_files,
               respondent: build(:respondent, :example_data, name: respondent_name))
      end

      before do
        response_to_repair.uploaded_files.find_by(filename: 'et3_atos_export.pdf').file.blob.delete
      end

      include_context 'with transactions off for use with other processes'
      include_context 'with fake sidekiq'
      include_context 'with setup for any response'
      include_context 'with background jobs running'
      include_examples 'any response variation'

      it 'includes the additional_information file in the exported data' do
        reference = response_to_repair.reference
        full_path = et_exporter.find_response_by_reference(reference).additional_information_file.path
        expect(full_path).to be_a_file_copy_of(Rails.root.join("spec/fixtures/example.rtf"))
      end
    end
  end
end
