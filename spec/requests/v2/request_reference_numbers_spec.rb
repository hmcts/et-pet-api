require 'rails_helper'
require 'securerandom'
RSpec.describe "V2 RequestReferenceNumbers", type: :request do
  describe "POST /api/v2/references/create_reference" do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:json_response) { JSON.parse(response.body) }
    let(:uuid) { SecureRandom.uuid }

    it "returns the correct status code" do
      # Act - Send a valid post code which should be found
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: 'SW1H 209ST'
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers

      # Assert - Make sure we get a 201 - to say the reference number is created
      expect(response).to have_http_status(:created)
    end

    it "returns the correct content type" do
      # Act - Send a valid post code which should be found
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: 'SW1H 209ST'
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers

      # Assert - Make sure we get a json content type in the response
      expect(response.headers['Content-Type']).to include 'application/json'
    end

    it "returns the correct response if the office is found" do
      # Act - Send a valid post code which should be found
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: 'SW1H 209ST'
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers

      # Assert - Make sure the response contains the correct data
      # apart from the fgr which is tested independently.
      expect(json_response).to include 'status' => 'created',
                                       'uuid' => uuid,
                                       'data' => a_hash_including(
                                         'office' => a_hash_including(
                                           'code' => '22',
                                           'name' => 'London Central',
                                           'address' => 'Victory House, 30-34 Kingsway, London WC2B 6EX',
                                           'telephone' => '020 7273 8603'
                                         ),
                                         'reference' => an_instance_of(String)
                                       )
    end

    it "returns the correct office if the office is found when it has spaces around post code" do
      # Act - Send a valid post code which should be found
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: ' SW1H 209ST '
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers

      # Assert - Make sure the response contains the correct data
      # apart from the fgr which is tested independently.
      expect(json_response).to include 'status' => 'created',
                                       'uuid' => uuid,
                                       'data' => a_hash_including(
                                         'office' => a_hash_including(
                                           'code' => '22',
                                           'name' => 'London Central',
                                           'address' => 'Victory House, 30-34 Kingsway, London WC2B 6EX',
                                           'telephone' => '020 7273 8603'
                                         ),
                                         'reference' => an_instance_of(String)
                                       )
    end

    it 'returns the correct reference number' do
      # Act - Send a valid post code which should be found
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: 'SW1H 209ST'
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers

      # Assert - Make sure the response contains fgr
      expect(json_response.dig('data', 'reference')).to match_regex(/\A22(\d{8,})00\z/)
    end

    it "returns the correct response if the office is not found" do
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: 'FF1 1ZZ'
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers

      expect(json_response).to include 'status' => 'created',
                                       'uuid' => uuid,
                                       'data' => a_hash_including(
                                         'office' => a_hash_including(
                                           'code' => '99',
                                           'name' => 'Default',
                                           'address' => 'Alexandra House, 14-22 The Parsonage, Manchester M3 2JA',
                                           'telephone' => '0161 833 6100'
                                         ),
                                         'reference' => an_instance_of(String)
                                       )
    end

    it "returns identical data if called twice with the same uuid" do
      # Arrange - call for the first time, save the response and reset the session ready for the second
      json_data = {
        uuid: uuid,
        command: 'CreateReference',
        async: false,
        data: {
          post_code: 'SW1H 209ST'
        }
      }
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers
      response1 = JSON.parse(response.body)
      reset!

      # Act - call for the second time
      post '/api/v2/references/create_reference', params: json_data.to_json, headers: default_headers
      response2 = JSON.parse(response.body)

      # Assert - Make sure they are identical
      expect(response1).to eq response2
    end
  end
end
