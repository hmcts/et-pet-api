require 'rails_helper'

RSpec.describe "RequestReferenceNumbers", type: :request do
  # content type "application/x-www-form-urlencoded"
  # body "postcode=SW1H%209ST"
  # accept application/json
  #
  describe "POST /api/v1/fgr-et-office" do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    end
    let(:json_response) { JSON.parse(response.body) }

    it "returns the correct status code" do
      # Act - Send a valid post code which should be found
      post '/api/v1/fgr-et-office', params: "postcode=SW1H%209ST", headers: default_headers

      # Assert - Make sure we get a 201 - to say the reference number is created
      expect(response).to have_http_status(:created)
    end

    it "returns the correct content type" do
      # Act - Send a valid post code which should be found
      post '/api/v1/fgr-et-office', params: "postcode=SW1H%209ST", headers: default_headers

      # Assert - Make sure we get a json content type in the response
      expect(response.headers['Content-Type']).to include 'application/json'
    end

    it "returns the correct response if the office is found" do
      # Act - Send a valid post code which should be found
      post '/api/v1/fgr-et-office', params: "postcode=SW1H%209ST", headers: default_headers

      # Assert - Make sure the response contains the correct data
      # apart from the fgr which is tested independently.
      expect(json_response).to include 'status' => 'ok',
                                       'fgr' => an_instance_of(String),
                                       'ETOfficeCode' => 22,
                                       'ETOfficeName' => 'London Central',
                                       'ETOfficeAddress' => 'Victory House, 30-34 Kingsway, London WC2B 6EX',
                                       'ETOfficeTelephone' => '020 7273 8603'
    end

    it 'returns the correct reference number' do
      # Act - Send a valid post code which should be found
      post '/api/v1/fgr-et-office', params: "postcode=SW1H%209ST", headers: default_headers

      # Assert - Make sure the response contains fgr
      expect(json_response['fgr']).to match_regex /\A22(\d{8,})00\z/
    end

    it "returns the correct response if the office is not found" do
      post '/api/v1/fgr-et-office', params: "postcode=FF1 1ZZ", headers: default_headers
      expect(json_response).to include 'status' => 'ok',
                                       'fgr' => an_instance_of(String),
                                       'ETOfficeCode' => 99,
                                       'ETOfficeName' => 'Default',
                                       'ETOfficeAddress' => 'Alexandra House, 14-22 The Parsonage, Manchester M3 2JA',
                                       'ETOfficeTelephone' => '0161 833 6100'
    end

    it 'returns a 422 if the wrong params are provided'
  end
end
