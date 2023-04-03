require 'rails_helper'
RSpec.describe 'Import Claim Request', type: :request do
  describe 'POST /api/v2/claims/repair_claim' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

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
        force_export_now
      end
    end

    shared_context 'with setup for claims' do
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

      # A private scrubber to set expectations for the filename - replaces white space with underscores and any non word chars are removed
      scrubber = ->(text) { text.gsub(/\s/, '_').gsub(/\W/, '') }

      let(:input_json) { build(:json_repair_claim_command, claim_id: claim_to_repair.id).as_json }

      let(:output_filename_pdf) { "#{claim_to_repair.reference}_ET1_#{scrubber.call claim_to_repair.primary_claimant.first_name}_#{scrubber.call claim_to_repair.primary_claimant.last_name}.pdf" }
      let(:output_filename_txt) { "#{claim_to_repair.reference}_ET1_#{scrubber.call claim_to_repair.primary_claimant.first_name}_#{scrubber.call claim_to_repair.primary_claimant.last_name}.txt" }
      let(:output_filename_additional_claimants_txt) { "#{claim_to_repair.reference}_ET1a_#{scrubber.call claim_to_repair.primary_claimant.first_name}_#{scrubber.call claim_to_repair.primary_claimant.last_name}.txt" }
      let(:output_filename_additional_claimants_csv) { "#{claim_to_repair.reference}_ET1a_#{scrubber.call claim_to_repair.primary_claimant.first_name}_#{scrubber.call claim_to_repair.primary_claimant.last_name}.csv" }

      before do
        perform_action
      end

      def perform_action
        post '/api/v2/claims/repair_claim', params: input_json.to_json, headers: default_headers
      end

      def force_export_now
        EtAtosExport::ClaimsExportJob.perform_now
      end
    end

    shared_examples 'any claim variation' do
      it 'returns the correct status code', background_jobs: :disable do
        # Assert - Make sure we get a 202 - to say the command has been accepted
        expect(response).to have_http_status(:accepted)
      end

      it 'returns status of ok', background_jobs: :disable do
        # Assert - make sure we get status of accepted
        expect(json_response).to include status: 'accepted'
      end

      it 'returns exactly the same data if called twice with the same uuid', background_jobs: :disable do
        # Arrange - get the response from the first call and reset the session ready for the second
        response1 = JSON.parse(response.body).with_indifferent_access
        reset!

        # Act - Make the call a second time
        perform_action
        response2 = JSON.parse(response.body).with_indifferent_access

        # Assert - Make sure its identical
        expect(response1).to eq response2
      end
    end

    shared_examples 'a claim exported to primary ATOS' do
      it 'stores the pdf file with the correct filename in the landing folder' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.all_unzipped_filenames).to include(output_filename_pdf)
      end

      it 'has the correct structure in the et1 txt file' do
        # Assert - look for the correct structure
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_correct_file_structure(errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary claimant in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        #
        claimant = claim_to_repair.primary_claimant.attributes.to_h.merge(address: claim_to_repair.primary_claimant.address.attributes.to_h).deep_symbolize_keys
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_claimant_for(claimant, errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary respondent in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        respondent = claim_to_repair.primary_respondent.attributes.to_h.merge(address: claim_to_repair.primary_respondent.address.attributes.to_h, work_address: claim_to_repair.primary_respondent.work_address.attributes.to_h).deep_symbolize_keys
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_respondent_for(respondent, errors: errors), -> { errors.join("\n") }
      end
    end


    include_context 'with fake sidekiq'
    include_context 'with setup for claims'
    include_context 'with background jobs running'

    context 'with multiple claim' do
      let(:claim_to_repair) { create(:claim, :example_data_multiple_claimants) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
    end
  end
end
