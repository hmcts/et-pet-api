require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Export Responses' do
  explanation "Used by the admin to request that a list of responses are exported to an external system such as CCD"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

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

  post '/api/v2/exports/export_responses' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "Contains the data for this command - in this case just the response_ids and the external_system_id", with_example: true, in: :body
    parameter :command, type: :string, enum: ['ExportResponses'], with_example: true, in: :body

    let(:example_external_system_reference) { 'ccd_manchester' }
    let(:example_external_system) { ExternalSystem.find_by_reference example_external_system_reference }
    let(:example_response) { create(:response) }

    context "202" do
      example 'Export an existing response' do
        request = FactoryBot.build(:json_export_responses_command, response_ids: [example_response.id], external_system_id: example_external_system.id).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end
    end

    context "400" do
      example 'Attempting to export a response to a non existent external system id' do
        request = FactoryBot.build(:json_export_responses_command, response_ids: [example_response.id], external_system_id: -1).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end

      example 'Attempting to export none existent responses' do
        request = FactoryBot.build(:json_export_responses_command, response_ids: [example_response.id, -1, -2], external_system_id: example_external_system.id).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end
    end

  end
end
