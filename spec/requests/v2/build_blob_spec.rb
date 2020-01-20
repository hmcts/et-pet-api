# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Build a blob using the configured cloud provider', type: :request do
  let(:default_headers) do
    {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  end

  describe 'POST /api/v2/build_blob in azure mode' do
    include_context 'with cloud provider switching', cloud_provider: :azure_test
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    it 'provides a response with the data in it' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_build_blob_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/build_blob', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response.dig(:data, :fields).symbolize_keys).to include key: starting_with("direct_uploads/")
    end

    it 'provides a response with the url in it' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_build_blob_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/build_blob', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response).to include data: a_hash_including(url: instance_of(String))
    end

    it 'provides a response with the signature in it' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_build_blob_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/build_blob', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response.dig(:data, :fields)).to include signature: instance_of(String)
    end

    it 'provides a response with the parts that make up the signature in it' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_build_blob_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/build_blob', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response.dig(:data, :fields)).to include version: instance_of(String),
                                                           permissions: instance_of(String),
                                                           expiry: instance_of(String),
                                                           resource: instance_of(String)
    end

    it 'provides a unique response every time' do
      # Arrange - build an array to store the results in
      response_keys = []

      # Act - Make the request
      5.times do
        json_data = FactoryBot.build(:json_build_blob_command).to_json
        post '/api/v2/build_blob', params: json_data, headers: default_headers
        response_keys << response.parsed_body["data"]["fields"]["key"]
      end

      # Assert - Make sure the data is in the response
      expect(response_keys.uniq.length).to eq 5
    end

    it 'identifies as an azure provider' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_build_blob_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/build_blob', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response).to include meta: a_hash_including(cloud_provider: 'azure')
    end

    it 'returns exactly the same data if called with the same uuid' do
      # Arrange - build the data, call the endpoint for the first time then reset the session ready for the main call
      json_data = FactoryBot.build(:json_build_blob_command).to_json
      post '/api/v2/build_blob', params: json_data, headers: default_headers
      response1 = JSON.parse(response.body).with_indifferent_access

      # Act - Make the request for a second time
      post '/api/v2/build_blob', params: json_data, headers: default_headers
      response2 = JSON.parse(response.body).with_indifferent_access

      # Assert - Make sure the repsonses are the same
      expect(response1).to eq response2
    end
  end
end
