# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Create Diversity Request', type: :request do
  describe 'POST /api/v2/diversity/build_diversity_response' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    context 'with a full data set' do
      let(:input_factory) { build(:json_build_diversity_response_command, :full) }

      it 'returns a created status' do
        # Act - Call the endpoint
        post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers

        # Assert
        expect(response).to have_http_status(:created)
      end

      it 'returns the uuid as a reference to what will be created', background_jobs: :disable do
        # Act - Call the endpoint
        post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers

        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'accepted', uuid: input_factory.uuid
      end

      it 'creates a new record in the database' do
        # Act - Call the endpoint
        action = lambda do
          post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers
        end

        # Assert
        expect(action).to change(DiversityResponse, :count).by(1)
      end

      it 'creates only 1 record if called twice' do
        # Act - Call the endpoint
        action = lambda do
          post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers
          post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers
        end

        # Assert
        expect(action).to change(DiversityResponse, :count).by(1)
      end

      it 'returns the same data if called twice' do
        # Arrange - call the endpoint for the first time, then reset the session ready for the second
        post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers
        response1 = JSON.parse(response.body).with_indifferent_access
        reset!

        # Act - Call the endpoint for the 2nd time
        post '/api/v2/diversity/build_diversity_response', params: input_factory.to_json, headers: default_headers
        response2 = JSON.parse(response.body).with_indifferent_access

        # Assert - Make sure they are the same
        expect(response1).to eq response2
      end
    end
  end
end
