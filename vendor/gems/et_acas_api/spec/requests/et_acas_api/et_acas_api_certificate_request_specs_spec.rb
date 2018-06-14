require 'rails_helper'

RSpec.describe "CertificateRequestSpecs", type: :request do
  let(:default_headers) do
    {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'EtUserId': 'my_user'
    }
  end
  let(:errors) { [] }
  let(:json_response) { JSON.parse(response.body).with_indifferent_access }
  let(:x509_private_key) { boom! }
  let(:x509_public_key) { boom! }

  # Fake External ACAS - note the example_get_certificate_url must match what is specified in the wsdl.txt file
  let(:wsdl_content) { File.read(File.absolute_path(File.join('..', '..', 'acas_interface_support', 'wsdl.txt'), __dir__)) }
  let(:example_get_certificate_url) { "https://localhost/Lookup/ECService.svc" }

  before do
    stub_request(:get, Rails.configuration.et_acas_api.wsdl_url).to_return body: wsdl_content, status: 200, headers: { 'Content-Type' => 'application/xml' }
  end

  describe "GET /et_acas_api_certificate_request_specs" do

    context 'with found response' do
      before do
        stub_request(:post, example_get_certificate_url).to_return body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' }
      end
      it 'provides the correct encrypted parameters to the acas service' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(mock_endpoint).to have_been_called.with(something: :need_to_work_out)
      end

      it 'decrypts and returns the response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response).to include(data: a_hash_including(something: :need_to_work_out))
      end
    end

    context 'with not found response' do
      it 'decrypts and returns the response as a 404' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(404)
      end
    end

    context 'with invalid certificate response' do
      it 'decrypts and returns the response as a 422' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(422)
      end

      it 'decrypts and returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response).to errors: a_collection_including(a_hash_including(id: a_hash_including(message: 'Invalid according to acas')))
      end
    end

    context 'with internal server error response' do
      it 'decrypts and returns the response as a 500' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(response).to have_http_status(500)
      end

      it 'decrypts and returns the response with a correct error response' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(json_response).to errors: a_collection_including(a_hash_including(message: 'Something went badly wrong'))
      end

      it 'decrypts and logs the error accordingly' do
        get '/et_acas_api/certificates/R000000/00/14', headers: default_headers
        expect(logger).to have_been_called_with(:something_to_be_decided)
      end
    end

    context 'with no request or response expected' do
      it 'returns 422 status when an invalid id is provided' do
        get '/et_acas_api/certificates/ZZ123456/16/20', headers: default_headers
        expect(response).to have_http_status(422)
      end

      it 'returns error information when invalid id is provided' do
        get '/et_acas_api/certificates/ZZ123456/16/20', headers: default_headers
        expect(json_response).to incude errors: a_collection_including(a_hash_including(id: a_hash_including(message: 'Invalid according to us')))
      end

      it 'does not request certificate from acas when an invalid id is provided' do
        get '/et_acas_api/certificates/ZZ123456/16/20', headers: default_headers
        expect(mock_endpoint).not_to have_been_called
      end
    end
  end
end
