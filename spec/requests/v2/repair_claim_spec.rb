require 'rails_helper'
RSpec.describe 'Repair Claim Request' do
  include_context 'with local storage'
  include_context 'with stubbed ccd'
  describe 'POST /api/v2/claims/repair_claim' do
    let(:default_headers) do
      {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    shared_context 'with background jobs running' do
      before do |example|
        next if example.metadata[:background_jobs] == :disable

        run_background_jobs
      end
    end

    shared_context 'with setup for claims' do
      # @return [EtApi::Test::CcdExporter] The exporter class to use for testing
      let(:ccd_exporter) { EtApi::Test::CcdExporter }

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

    shared_examples 'a claim exported to ccd' do
      it 'exports the repaired claimant, respondent and PDF to CCD' do
        exported_claim = ccd_exporter.find_claim_by_submission_reference(claim_to_repair.reference)

        aggregate_failures 'validating repaired CCD export' do
          aggregate_failures 'primary claimant' do
            claimant = claim_to_repair.primary_claimant.attributes.as_json.merge(
              address_attributes: claim_to_repair.primary_claimant.address.attributes.as_json
            ).deep_symbolize_keys
            exported_claim.assert_primary_claimant(claimant)
          end

          aggregate_failures 'primary respondent' do
            respondent = claim_to_repair.primary_respondent.attributes.as_json.merge(
              address_attributes: claim_to_repair.primary_respondent.address.attributes.as_json,
              work_address_attributes: claim_to_repair.primary_respondent.work_address.attributes.as_json
            ).deep_symbolize_keys
            exported_claim.assert_primary_respondent(respondent)
          end

          aggregate_failures 'completed PDF' do
            expect(exported_claim.et1_pdf_file(template: claim_to_repair.pdf_template_reference)).to be_present
          end
        end
      end
    end

    include_context 'with fake job processor'
    include_context 'with setup for claims'
    include_context 'with background jobs running'

    context 'with multiple claim' do
      let(:claim_to_repair) do
        create(:claim, :example_data_multiple_claimants, office_code: 24).tap do |claim|
          claim.uploaded_files << build(:uploaded_file, :example_pdf, :system_file_scope, filename: 'et1_first_last_trimmed.pdf')
        end
      end

      it_behaves_like 'any claim variation'
      it_behaves_like 'a claim exported to ccd'
    end
  end
end
