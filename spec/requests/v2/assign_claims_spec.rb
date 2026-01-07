# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Assign Claim Request' do
  include_context 'with local storage'
  include_context 'with gov uk notify emails sent monitor'

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
      prepare_local_active_storage
      previous_value = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      ActiveJob::Base.queue_adapter.enqueued_jobs.delete_if do |job|
        return false unless job[:job] == EventJob

        job[:job].perform_now(*ActiveJob::Arguments.deserialize(job[:args]))
        true
      end
    ensure
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = previous_value
    end
  end

  describe 'POST /api/v2/claims/assign_claim' do
    let(:default_headers) do
      {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }
    let(:example_claim_reference) do
      command = build(:json_build_claim_commands)
      post '/api/v2/claims/build_claim', params: command.to_json, headers: default_headers
      response.parsed_body.dig('meta', 'BuildClaim', 'reference').tap do
        run_background_jobs # So the claim is exported to the right place before the test changes the office
        reset!
      end

    end
    let(:example_claim) { Claim.find_by reference: example_claim_reference }
    let(:new_office) { Office.find_by(code: 24) }
    let(:example_user_id) { 123 }

    include_context 'with fake sidekiq'

    it 'returns 202 accepted' do
      # Arrange - Setup the claim record and provide the ids
      command = build(:json_assign_claim_command, claim_id: example_claim.id, office_id: new_office.id, user_id: example_user_id)

      # Act - Run the command and all background jobs
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers

      # Assert - Check the http status
      expect(response).to have_http_status(:accepted)
    end

    it 'creates a new export record with the correct status' do
      # Arrange - Setup the response record and provide the ids
      command = build(:json_assign_claim_command, claim_id: example_claim.id, office_id: new_office.id, user_id: example_user_id)

      # Act - Run the command and all background jobs
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers
      run_background_jobs

      # Assert - Check the example claim now has an export record and will be marked as queued
      claim = Claim.find_by(reference: example_claim_reference)
      expect(Export.where(external_system_id: ExternalSystem.containing_office_code(new_office.code).exporting_claims.first.id, resource: claim, state: 'queued').count).to be 1
    end

    it 'returns identical data if called twice with the same uuid', background_jobs: :disable do
      # Arrange - get the response from the first call and reset the session ready for the second
      command = build(:json_assign_claim_command, claim_id: example_claim.id, office_id: new_office.id, user_id: example_user_id)
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers
      response1 = JSON.parse(response.body).with_indifferent_access
      reset!

      # Act - Call the endpoint for the second time
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers
      response2 = JSON.parse(response.body).with_indifferent_access

      # Arrange - check they are identical
      expect(response1).to eq response2
    end

    it 'creates no more records if called a second time with same uuid', background_jobs: :disable do
      # Arrange - setup the action to perform twice, but call it once in setup
      command = build(:json_assign_claim_command, claim_id: example_claim.id, office_id: new_office.id, user_id: example_user_id)
      perform_action = lambda {
        post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers
        run_background_jobs
      }
      perform_action.call
      reset!

      # Assert
      expect { perform_action }.not_to change(Export, :count)
    end

    it 'creates events in the claim' do
      # Arrange - Setup the claim record and provide the ids
      command = build(:json_assign_claim_command, claim_id: example_claim.id, office_id: new_office.id, user_id: example_user_id)

      # Act - Run the command and all background jobs
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers

      # Assert - check the database for the events
      expect(example_claim.reload.events.claim_manually_assigned.last.data).to include 'office_code' => new_office.code,
                                                                                       'user_id' => example_user_id
    end

    it 'returns errors if the office is not found' do
      # Arrange - Setup the claim record and provide the ids
      command = build(:json_assign_claim_command, claim_id: example_claim.id, office_id: -1, user_id: example_user_id)

      # Act - Run the command and all background jobs
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers

      # Assert - Check the response is a bad request with the error message populated
      aggregate_failures 'validate status and body' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response).to include \
          "status" => "not_accepted",
          "uuid" => command.uuid,
          "errors" => a_collection_including(
            a_hash_including("status" => 422,
                             "code" => "office_not_found",
                             "command" => "AssignClaim",
                             "detail" => "The office with an id of -1 was not found")
          )
      end
    end

    it 'returns error if claim not found' do
      # Arrange - Setup the response record and provide the ids
      command = build(:json_assign_claim_command, claim_id: -1, office_id: new_office.id, user_id: example_user_id)

      # Act - Run the command and all background jobs
      post '/api/v2/claims/assign_claim', params: command.to_json, headers: default_headers

      # Assert - Check the response is a bad request with the error message populated
      aggregate_failures 'validate status and body' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response).to include \
          "status" => "not_accepted",
          "uuid" => command.uuid,
          "errors" => a_collection_including(
            a_hash_including("status" => 422,
                             "code" => "claim_not_found",
                             "command" => "AssignClaim",
                             "detail" => "A claim with an id of -1 was not found")
          )
      end
    end
  end
end
