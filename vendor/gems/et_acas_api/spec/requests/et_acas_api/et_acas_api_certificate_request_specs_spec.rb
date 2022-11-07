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
  let(:example_get_certificate_url) { Rails.configuration.et_acas_api.json_service_url }


  describe "GET /et_acas_api_certificate_request_specs" do
    context 'with found response' do
      before do
        stub_request(:post, example_get_certificate_url).to_return do |r|
          { body: [response_factory].to_json, status: response_factory.response_code.to_i, headers: { 'Content-Type' => 'application/json' } }
        end
      end
      let(:response_factory) { build(:json_valid_acas_response, :valid) }

      it 'returns the response' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(json_response[:data].symbolize_keys).to include(
          claimant_name: nil,
          respondent_name: nil,
          certificate_number: response_factory.certificate_number,
          message: nil,
          method_of_issue: nil,
          date_of_issue: nil,
          date_of_receipt: nil,
          certificate_base64: Base64.encode64(File.read(response_factory.certificate_file))
        )
      end

      it 'returns a status of found' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(json_response).to include(status: 'found')
      end


      it 'stores found response in download log' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        log = EtAcasApi::DownloadLog.find_by!(certificate_number: response_factory.certificate_number)
        expect(log).to have_attributes message: 'CertificateFound',
          description: 'Certificate Search Success',
          method_of_issue: nil,
          user_id: 'my_user'
      end
    end

    context 'with not found response' do
      before do
        stub_request(:post, example_get_certificate_url).to_return do |r|
          { body: [response_factory].to_json, status: response_factory.response_code.to_i, headers: { 'Content-Type' => 'application/json' } }
        end
      end
      let(:response_factory) { build(:json_valid_acas_response, :not_found) }

      it 'returns the response as a 404' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(response).to have_http_status(404)
      end

      it 'stores no match response in download log' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        log = EtAcasApi::DownloadLog.find_by!(certificate_number: 'R000080/18/59')
        expect(log).to have_attributes message: 'Certificate Not Found',
          description: 'Certificate Search Failure',
          method_of_issue: nil,
          user_id: 'my_user'
      end
    end

    context 'with internal server error response' do
      before do
        stub_request(:post, example_get_certificate_url).to_return do |r|
          { body: response_factory.to_json, status: response_factory.response_code.to_i, headers: { 'Content-Type' => 'application/json' } }
        end
      end
      let(:response_factory) { build(:json_valid_acas_response, :acas_server_error) }

      it 'returns the response as a 500' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(response).to have_http_status(500)
      end

      it 'returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(base: a_collection_including('An error occured in the ACAS service'))
      end

      it 'logs the error accordingly' do
        logger = Rails.logger
        expect(logger).to receive(:warn).with("An error occured in the ACAS server when trying to find certificates 'R000080/18/59' - the error reported was '#{response_factory.message}'").and_call_original
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
      end

      it 'stores internal error response in download log' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        log = EtAcasApi::DownloadLog.find_by!(certificate_number: 'R000080/18/59')
        expect(log).to have_attributes message: 'Internal Server Error',
          description: 'Certificate Search Failure',
          method_of_issue: nil,
          user_id: 'my_user'
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
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(response).to have_http_status(500)
      end

      it 'returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(base: a_collection_including('An error occured connecting to the ACAS service'))
      end

      it 'logs the error accordingly' do
        logger = Rails.logger
        expect(logger).to receive(:warn).with("An error occured connecting to the ACAS server when trying to find certificates 'R000080/18/59' - the error reported was 'execution expired'").and_call_original
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
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
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(response).to have_http_status(400)
      end

      it 'returns a correct error response' do
        get '/et_acas_api/certificates/R000080/18/59', headers: default_headers
        expect(json_response[:errors].symbolize_keys).to include(user_id: a_collection_including('Missing user id'))
      end
    end
  end
end
