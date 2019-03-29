# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Validate Claimants File Request', type: :request do
  include_context 'with cloud provider switching', cloud_provider: :azure
  describe 'POST /api/v2/validate' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    context 'with valid input data' do
      let(:input_factory) do
        FactoryBot.build(:json_validate_claimants_file_command, :valid)
      end

      it 'returns 200 success' do
        # Arrange - Get the json data
        json_data = input_factory.to_json

        # Act - Call the endpoint
        post '/api/v2/validate', params: json_data, headers: default_headers

        # Assert - Make sure we get a 200 response
        expect(response).to(have_http_status(:ok))
      end
    end

    context 'with invalid input data' do
      let(:input_factory) do
        FactoryBot.build(:json_validate_claimants_file_command, :invalid)
      end

      before do
        # Arrange - Get the json data
        json_data = input_factory.to_json

        # Act - Call the endpoint
        post '/api/v2/validate', params: json_data, headers: default_headers
      end

      it 'returns 400 bad request' do
        # Assert - Make sure we get a 200 response
        expect(response).to(have_http_status(:bad_request))
      end

      it 'returns the status  as not accepted' do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'not_accepted', uuid: input_factory.uuid
      end

      it 'has the correct json pointer in the error' do
        # Assert - Make sure we get the json pointer in the response
        expect(json_response.deep_symbolize_keys).to include errors: a_collection_including(
          hash_including(source: '/data_from_key/0/date_of_birth', code: 'invalid', title: 'is invalid', command: input_factory.command, uuid: input_factory.uuid),
          hash_including(source: '/data_from_key/1/title', code: 'inclusion', title: 'is not included in the list', command: input_factory.command, uuid: input_factory.uuid)
        )
      end
    end
  end
end
