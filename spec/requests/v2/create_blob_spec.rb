# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a blob in the direct upload storage', type: :request do
  let(:default_headers) do
    {
      Accept: 'application/json',
      'Content-Type': 'multipart/form-data'
    }
  end
  let(:json_response) { JSON.parse(response.body).with_indifferent_access }

  describe 'POST /api/v2/create_blob' do
    it 'stores the csv file as a blob in the direct upload storage and identifies the content type as csv' do
      post '/api/v2/create_blob', params: { file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/simple_user_with_csv_group_claims.csv'), 'application/csv', false) }, headers: default_headers
      expect(json_response).to include data: a_hash_including(key: instance_of(String), content_type: 'application/csv', filename: 'simple_user_with_csv_group_claims.csv')
    end

    it 'stores the additional information file as a blob in the direct upload storage and identifies the content type as rtf' do
      post '/api/v2/create_blob', params: { file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf'), 'application/rtf', false) }, headers: default_headers
      expect(json_response).to include data: a_hash_including(key: instance_of(String), content_type: 'application/rtf', filename: 'simple_user_with_rtf.rtf')
    end

    it 'has an error response when an incorrect file extension is provided' do
      post '/api/v2/create_blob', params: { file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/invalid_content_type.rtf'), 'application/rtf', false) }, headers: default_headers
      expect(json_response).to include errors: include(a_hash_including(code: "mismatching_file_content_type")),
                                       status: 'not_accepted',
                                       uuid: an_instance_of(String)
    end
  end
end
