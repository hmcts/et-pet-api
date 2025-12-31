require 'rails_helper'
RSpec.describe 'Import Claim Request' do
  include_context 'with local storage'
  describe 'POST /api/v2/claims/repair_claim' do
    let(:default_headers) do
      {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

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

    shared_context 'with setup for claims' do
      # @return [EtApi::Test::EtExporter] The exporter class to use for testing
      let(:et_exporter) { EtApi::Test::EtExporter }

      let(:emails_sent) do
        EtApi::Test::EmailsSent.new
      end

      let(:input_json) { build(:json_repair_claim_command, claim_id: claim_to_repair.id).as_json }

      before do
        perform_action
      end

      def perform_action
        post '/api/v2/claims/repair_claim', params: input_json.to_json, headers: default_headers
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

    shared_examples 'a claim exported to et_exporter' do
      it 'has the primary claimaint in the payload' do
        submission_reference = claim_to_repair.submission_reference
        claimant = claim_to_repair.primary_claimant.attributes.as_json.merge(address: claim_to_repair.primary_claimant.address.attributes.as_json).deep_symbolize_keys
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_primary_claimant(claimant)
      end

      it 'has the primary respondent in the payload' do
        submission_reference = claim_to_repair.submission_reference
        respondent = claim_to_repair.primary_respondent.attributes.to_h.merge(address: claim_to_repair.primary_respondent.address.attributes.to_h, work_address: claim_to_repair.primary_respondent.work_address.attributes.to_h).deep_symbolize_keys
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_primary_respondent(respondent)
      end

      it 'creates a valid pdf file with the data filled in correctly' do
        submission_reference = claim_to_repair.submission_reference
        expect(et_exporter.find_claim_by_submission_reference(submission_reference).et1_pdf_file(template: claim_to_repair.pdf_template_reference)).to be_present
      end

    end

    include_context 'with fake sidekiq'
    include_context 'with setup for claims'
    include_context 'with background jobs running'

    context 'with multiple claim' do
      let(:claim_to_repair) { create(:claim, :example_data_multiple_claimants) }

      it_behaves_like 'any claim variation'
      it_behaves_like 'a claim exported to et_exporter'
    end
  end
end
