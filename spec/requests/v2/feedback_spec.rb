# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Create Feedback Request', type: :request do
  describe 'POST /api/v2/feedback/build_feedback_response' do
    let(:default_headers) do
      {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
      }
    end
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

    context 'with a full data set' do
      let(:input_factory) { build(:json_build_feedback_response_command, :full) }
      let(:feedback_factory) { build(:json_feedback_data, :full) }
      let(:email_sent) { EtApi::Test::EmailsSent.new }
      include_context 'with fake sidekiq'
      it 'returns a created status' do
        # Act - Call the endpoint
        post '/api/v2/feedback/build_feedback', params: input_factory.to_json, headers: default_headers

        # Assert
        expect(response).to have_http_status(:created)
      end

      it 'returns the uuid as a reference to what will be created', background_jobs: :disable do
        # Act - Call the endpoint
        post '/api/v2/feedback/build_feedback', params: input_factory.to_json, headers: default_headers

        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'accepted', uuid: input_factory.uuid
      end

      it 'sends an HTML email to the feedback user' do
        # Act - Call the endpoint
        post '/api/v2/feedback/build_feedback', params: input_factory.to_json, headers: default_headers
        run_background_jobs
        my_email = email_sent.new_feedback_email_html_for(email_address: input_factory.data.email_address, template_reference: 'et3-v1-en')
        expect(my_email).to have_correct_content_for(input_factory.data)
      end

      it 'sends an text email to the feedback user' do
        # Act - Call the endpoint
        post '/api/v2/feedback/build_feedback', params: input_factory.to_json, headers: default_headers
        run_background_jobs
        my_email = email_sent.new_feedback_email_text_for(email_address: input_factory.data.email_address, template_reference: 'et3-v1-en')
        expect(my_email).to have_correct_content_for(input_factory.data)
      end
    end
  end
end
