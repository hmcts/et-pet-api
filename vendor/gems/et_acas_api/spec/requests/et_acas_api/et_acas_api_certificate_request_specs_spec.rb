require 'rails_helper'

RSpec.describe "CertificateRequestSpecs", type: :request do
  let(:default_headers) do
    {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'EtUserId': 'my_user'
    }
  end
  let(:json_response) { JSON.parse(response.body).with_indifferent_access }

  # Fake External ACAS - note the example_get_certificate_url must match what is specified in the rails config
  let(:example_get_certificate_url) { Rails.configuration.et_acas_api.service_url }


  describe "GET /et_acas_api_certificate_request_specs" do
    recorded_request = nil
    before do
      recorded_request = nil
      stub_request(:post, example_get_certificate_url).to_return do |r|
        recorded_request = r
        { body: response_factory.to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' } }
      end
    end

    context 'with found response' do
      let(:response_factory) { build(:soap_valid_acas_response, :valid) }
      it 'provides the correct encrypted parameters - apart from date - to the acas service' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(recorded_request.body).to have_valid_encrypted_parameters_for_acas(
          ECCertificateNumber: 'R000000/00/14',
          UserId: 'my_user'
        )
      end

      it 'provides the correct date - to the acas service' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(recorded_request.body).to have_valid_current_date_time_for_acas
      end

      it 'provides the correct signature for the acas service' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(recorded_request.body).to have_valid_signature_for_acas
      end

      it 'decrypts and returns the response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response[:data].symbolize_keys).to include(
          claimant_name: response_factory.claimant_name,
          respondent_name: response_factory.respondent_name,
          certificate_number: response_factory.certificate_number,
          message: response_factory.message,
          method_of_issue: response_factory.method_of_issue,
          date_of_issue: response_factory.date_of_issue.iso8601(3),
          date_of_receipt: response_factory.date_of_receipt.iso8601(3),
          certificate_base64: Base64.encode64(File.read(response_factory.certificate_file))
        )
      end

      it 'returns a status of found' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response).to include(status: 'found')
      end
    end

    context 'with not found response' do
      let(:response_factory) { build(:soap_valid_acas_response, :not_found) }

      it 'decrypts and returns the response as a 404' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(404)
      end
    end

    context 'with invalid certificate response' do
      let(:response_factory) { build(:soap_valid_acas_response, :invalid_certificate_format) }
      it 'decrypts and returns the response as a 422' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(422)
      end

      it 'decrypts and returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(id: a_collection_including('Invalid certificate format'))
      end
    end

    context 'with internal server error response' do
      let(:response_factory) { build(:soap_valid_acas_response, :acas_server_error) }
      it 'decrypts and returns the response as a 500' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(500)
      end

      it 'decrypts and returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(base: a_collection_including('An error occured in the ACAS service'))
      end

      it 'decrypts and logs the error accordingly' do
        logger = Rails.logger
        expect(logger).to receive(:warn).with("An error occured in the ACAS server when trying to find certificate 'R000000/00/14' - the error reported was '#{response_factory.message}'").and_call_original
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
      end
    end

    context 'with no request or response expected' do
      it 'returns 422 status when an invalid id is provided' do
        get '/et_acas_api/certificates/ZZ123456/16/20', headers: default_headers
        expect(response).to have_http_status(422)
      end

      it 'returns error information when invalid id is provided' do
        get '/et_acas_api/certificates/ZZ123456/16/20', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include id: a_collection_including('Invalid certificate format')
      end

      it 'does not request certificate from acas when an invalid id is provided' do
        get '/et_acas_api/certificates/ZZ123456/16/20', headers: default_headers
        expect(a_request(:post, example_get_certificate_url)).not_to have_been_made
      end
    end

    context 'with timeout from server' do
      before do
        stub_request(:post, example_get_certificate_url).to_timeout
      end

      it 'returns an error 500' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(500)
      end

      it 'returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(base: a_collection_including('An error occured connecting to the ACAS service'))
      end

      it 'logs the error accordingly' do
        logger = Rails.logger
        expect(logger).to receive(:warn).with("An error occured connecting to the ACAS server when trying to find certificate 'R000000/00/14' - the error reported was 'execution expired'").and_call_original
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
      end
    end

    context 'with missing EtUserId header' do
      let(:default_headers) do
        {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
      end

      it 'returns an error 400' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(400)
      end

      it 'returns a correct error response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(user_id: a_collection_including('Missing user id'))
      end
    end
  end
end
