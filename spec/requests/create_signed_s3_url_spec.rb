# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create signed S3 url request', type: :request do
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
      expect(json_response).to include data: a_hash_including(fields: {
        key: "direct_uploads/#{json_factory.data[:key]}",
        acl: instance_of(String),
        success_action_redirect: a_string_ending_with('successful_upload.html'),
        'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
        'X-Amz-Credential': a_string_matching(/\A[^\/]*\/\d{8}\/s3\/aws4_request\z/),
        'X-Amz-Date': a_string_matching(/\A\d{8}T\d{6}Z\z/),
        'x-amz-meta-uuid': instance_of(String),
        'x-amz-server-side-encryption': 'AES256',
        'x-amz-meta-tag': '',
        Policy: instance_of(String),
        'X-Amz-Signature': instance_of(String)
      })
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
  end
end
