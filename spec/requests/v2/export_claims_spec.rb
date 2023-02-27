# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Export Claims Request', type: :request do
  include_context 'with local storage'
  include_context 'with gov uk notify emails sent monitor'

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

  describe 'POST /api/v2/exports/export_claims' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }
    let(:example_claim_reference) do
      command = FactoryBot.build(:json_build_claim_commands)
      post '/api/v2/claims/build_claim', params: command.to_json, headers: default_headers
      JSON.parse(response.body).dig('meta', 'BuildClaim', 'reference').tap { reset! }
    end
    let(:example_external_system_reference) { 'ccd_manchester' }
    let(:example_external_system) { ExternalSystem.find_by_reference example_external_system_reference }
    let(:example_claim) { Claim.find_by_reference example_claim_reference }


    include_context 'with fake sidekiq'

    it 'returns 202 accepted' do
      # Arrange - Setup the claim record and provide the ids
      command = FactoryBot.build(:json_export_claims_command, claim_ids: [example_claim.id], external_system_id: example_external_system.id)

      # Act - Run the command and all background jobs
      post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers

      # Assert - Check the http status
      expect(response).to have_http_status(:accepted)
    end

    it 'creates a new export record with the correct status' do
      # Arrange - Setup the response record and provide the ids
      command = FactoryBot.build(:json_export_claims_command, claim_ids: [example_claim.id], external_system_id: example_external_system.id)

      # Act - Run the command and all background jobs
      post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers
      run_background_jobs

      # Assert - Check the example claim now has an export record and will be marked as queued
      claim = Claim.find_by_reference(example_claim_reference)
      expect(Export.where(external_system_id: example_external_system.id, resource: claim, state: 'queued').count).to be 1
    end

    it 'returns identical data if called twice with the same uuid', background_jobs: :disable do
      # Arrange - get the response from the first call and reset the session ready for the second
      command = FactoryBot.build(:json_export_claims_command, claim_ids: [example_claim.id], external_system_id: example_external_system.id)
      post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers
      response1 = JSON.parse(response.body).with_indifferent_access
      reset!

      # Act - Call the endpoint for the second time
      post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers
      response2 = JSON.parse(response.body).with_indifferent_access

      # Arrange - check they are identical
      expect(response1).to eq response2
    end

    it 'creates no more records if called a second time with same uuid', background_jobs: :disable do
      # Arrange - setup the action to perform twice, but call it once in setup
      command = FactoryBot.build(:json_export_claims_command, claim_ids: [example_claim.id], external_system_id: example_external_system.id)
      perform_action = -> {
        post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers
        run_background_jobs
      }
      perform_action.call
      reset!

      # Assert
      expect { perform_action }.not_to change(Export, :count)
    end

    it 'returns errors if the external_system is not found' do
      # Arrange - Setup the claim record and provide the ids
      command = FactoryBot.build(:json_export_claims_command, claim_ids: [example_claim.id], external_system_id: -1)

      # Act - Run the command and all background jobs
      post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers

      # Assert - Check the response is a bad request with the error message populated
      aggregate_failures 'validate status and body' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response).to include \
          "status" => "not_accepted",
          "uuid" => command.uuid,
          "errors" => a_collection_including(
                        a_hash_including "status" => 422,
                                         "code" => "external_system_not_found",
                                         "command" => "ExportClaims",
                                         "detail" => "The external system with an id of -1 was not found"
          )
      end
    end

    it 'returns errors if multiple claims are not found' do
      # Arrange - Setup the response record and provide the ids
      command = FactoryBot.build(:json_export_claims_command, claim_ids: [example_claim.id, -1, -2], external_system_id: example_external_system.id)

      # Act - Run the command and all background jobs
      post '/api/v2/exports/export_claims', params: command.to_json, headers: default_headers

      # Assert - Check the response is a bad request with the error message populated
      aggregate_failures 'validate status and body' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response).to include \
          "status" => "not_accepted",
          "uuid" => command.uuid,
          "errors" => a_collection_including(
                        a_hash_including("status" => 422,
                                         "code" => "claim_not_found",
                                         "command" => "ExportClaims",
                                         "detail" => "A claim with an id of -1 was not found"),
                        a_hash_including("status" => 422,
                                         "code" => "claim_not_found",
                                         "command" => "ExportClaims",
                                         "detail" => "A claim with an id of -2 was not found")

          )
      end
    end
  end
end
