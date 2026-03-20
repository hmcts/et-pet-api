# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate Additional Information File Request', type: :request do
  include_context 'with local storage'

  describe 'POST /api/v2/validate' do
    let(:default_headers) do
      {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    context 'with valid input data' do
      let(:input_factory) { build(:json_validate_additional_information_file_command, :valid) }

      it 'returns 200 success' do
        post '/api/v2/validate', params: input_factory.to_json, headers: default_headers

        expect(response).to have_http_status(:ok)
      end

      it 'returns the status as accepted' do
        post '/api/v2/validate', params: input_factory.to_json, headers: default_headers

        expect(json_response).to include status: 'accepted', uuid: input_factory.uuid
      end
    end

    context 'with a password protected file' do
      let(:input_factory) { build(:json_validate_additional_information_file_command, :password_protected) }

      before do
        post '/api/v2/validate', params: input_factory.to_json, headers: default_headers
      end

      it 'returns 422 bad request' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the status as not accepted' do
        expect(json_response).to include status: 'not_accepted', uuid: input_factory.uuid
      end

      it 'has the correct json pointer in the error' do
        expect(json_response.deep_symbolize_keys).to include errors: a_collection_including(
          hash_including(source: '/data_from_key', code: 'password_protected', title: "This file is password protected. Upload a file that isn’t password protected.", command: input_factory.command, uuid: input_factory.uuid, options: {})
        )
      end
    end
  end
end
