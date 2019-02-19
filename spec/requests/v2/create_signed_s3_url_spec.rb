# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create signed S3 url request', type: :request do
  include_context 'with cloud provider switching', cloud_provider: :amazon
  describe 'POST /api/v2/s3/create_signed_url' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    it 'provides a response with the data in it' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_create_signed_s3_url_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/s3/create_signed_url', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response.dig(:data, :fields).symbolize_keys).to include key: starting_with("direct_uploads/"),
                                                                          'x-amz-algorithm': 'AWS4-HMAC-SHA256',
                                                                          'x-amz-credential': a_string_matching(%r{\A[^\/]*\/\d{8}\/us-east-1\/s3\/aws4_request\z}),
                                                                          'x-amz-date': match_regex(/\A\d{8}T\d{6}Z\z/),
                                                                          policy: instance_of(String),
                                                                          'x-amz-signature': instance_of(String),
                                                                          'success_action_status': '201'

    end

    it 'provides a response with the post url in it' do
      # Arrange - build the data
      json_factory = FactoryBot.build(:json_create_signed_s3_url_command)
      json_data = json_factory.to_json

      # Act - Make the request
      post '/api/v2/s3/create_signed_url', params: json_data, headers: default_headers

      # Assert - Make sure the data is in the response
      expect(json_response).to include data: a_hash_including(url: instance_of(String))
    end

    it 'provides a unique response every time' do
      # Arrange - build the data
      response_keys = []
      json_factory = FactoryBot.build(:json_create_signed_s3_url_command)
      json_data = json_factory.to_json

      # Act - Make the request
      5.times do
        post '/api/v2/s3/create_signed_url', params: json_data, headers: default_headers
        response_keys << response.parsed_body["data"]["fields"]["key"]
      end

      # Assert - Make sure the data is in the response
      expect(response_keys.uniq.length).to eq 5
    end
  end
end
