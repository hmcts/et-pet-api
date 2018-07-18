# frozen_string_literal: true

require 'rails_helper'

# This spec uses the 'Et Fake Acas Server' which provides a different response based on the
# certificate number requested.  The last 3 digits of the first part of the number identifies the
# acas response wanted.  (100, 200, 201 or 500)
RSpec.describe 'GetAcasCertificate Request', type: :request do
  describe '/et_acas_api/certificates/<id>' do
    before do
      stub_request(:any, /fakeservice\.com/).to_rack(EtFakeAcasServer::Server)
    end
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'EtUserId': 'my_user'
      }
    end
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    it 'handles found response' do
      get '/et_acas_api/certificates/R000100/00/14', headers: default_headers
      expect(json_response[:data].symbolize_keys).to include(
        claimant_name: 'Claimant Name',
        respondent_name: 'Respondent Name',
        certificate_number: 'R000100/00/14',
        message: 'Certificate found',
        method_of_issue: 'Email',
        date_of_issue: "2017-12-01T12:00:00.000Z",
        date_of_receipt: "2017-01-01T12:00:00.000Z"
      )
    end

    it 'handles no match response' do
      get '/et_acas_api/certificates/R000200/00/14', headers: default_headers
      expect(json_response).to include(status: 'not_found')
    end

    it 'handles invalid certificate response' do
      get '/et_acas_api/certificates/R000201/00/14', headers: default_headers
      expect(json_response).to include(status: 'invalid_certificate_format')
    end

    it 'handles internal error response' do
      get '/et_acas_api/certificates/R000500/00/14', headers: default_headers
      expect(json_response).to include(status: 'acas_server_error')
    end
  end
end
