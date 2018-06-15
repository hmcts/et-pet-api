# frozen_string_literal: true

require 'rails_helper'

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

    it 'appears to be delegating to the et_acas_api gem correctly' do
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
  end
end
