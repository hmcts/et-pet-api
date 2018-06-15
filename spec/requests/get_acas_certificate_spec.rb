# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GetAcasCertificate Request', type: :request do
  describe '/et_acas_api/certificates/<id>' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'EtUserId': 'my_user'
      }
    end
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    it 'appears to be delegating to the et_acas_api gem correctly' do
      get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
      expect(json_response[:data].symbolize_keys).to include(
                                                       claimant_name: response_factory.claimant_name,
                                                       respondent_name: response_factory.respondent_name,
                                                       certificate_number: response_factory.certificate_number,
                                                       message: response_factory.message,
                                                       method_of_issue: response_factory.method_of_issue,
                                                       date_of_issue: response_factory.date_of_issue.iso8601(3),
                                                       date_of_receipt: response_factory.date_of_receipt.iso8601(3)
                                                     )
    end
  end
end
