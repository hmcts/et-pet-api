require 'rails_helper'
RSpec.describe EtAcasApi::AcasApiService do
  subject(:api) { described_class.new config }
  let(:config) { {
      wsdl_url: 'http://mydomain.com/my.wsdl',
      current_time: Time.zone.parse('31/12/2017 18:00:00'),
      acas_rsa_certificate_path: File.absolute_path(File.join('..', '..', 'acas_interface_support', 'x509', 'theirs', 'publickey.cer'), __dir__),
      rsa_certificate_path: File.absolute_path(File.join('..', '..', 'acas_interface_support', 'x509', 'ours', 'publickey.cer'), __dir__),
      rsa_private_key_path: File.absolute_path(File.join('..', '..', 'acas_interface_support', 'x509', 'ours', 'privatekey.pem'), __dir__)
  } }

  # Common Setup - A fake wsdl response to provide a fake url for this service
  let(:example_get_certificate_url) { "https://localhost/Lookup/ECService.svc" }
  let(:wsdl_content) { File.read(File.absolute_path(File.join('..', '..', 'acas_interface_support', 'wsdl.txt'), __dir__)) }
  before do
    stub_request(:get, 'http://mydomain.com/my.wsdl').to_return body: wsdl_content, status: 200, headers: { 'Content-Type' => 'application/xml' }
  end

  describe '#get_certificate' do
    it 'requests the data from the correct entry in the wsdl' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: '', status: 200, headers: { 'Content-Type' => 'application/xml' }
      subject.get_certificate('anyid', user_id: "my user id")
      expect(get_certificate_stub).to have_been_requested
    end

    it 'requests the data with the correct input parameters' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: '', status: 200, headers: { 'Content-Type' => 'application/xml' }
      subject.get_certificate('anyid', user_id: "my user id")
      body_matcher = hash_including('env:Envelope' =>
                                        hash_including('env:Body' =>
                                                           hash_including('tns:GetECCertificate' =>
                                                                              hash_including(
                                                                                  'tns:ECCertificateNumber' => equals_encrypted_param_for_acas('anyid'),
                                                                                  'tns:UserId' => equals_encrypted_param_for_acas('my user id'),
                                                                                  'tns:CurrentDateTime' => equals_encrypted_param_for_acas('31/12/2017 18:00:00')
                                                                              ))))
      expect(get_certificate_stub.with(body: body_matcher)).to have_been_requested
    end

    it 'requests the data with the correct security token in the signature in the header' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: '', status: 200, headers: { 'Content-Type' => 'application/xml' }
      subject.get_certificate('anyid', user_id: "my user id")
      our_base64_public_key = Base64.encode64(OpenSSL::X509::Certificate.new(File.read(config[:rsa_certificate_path])).to_der).tr("\n", '')
      body_matcher = hash_including('env:Envelope' =>
                                        hash_including(
                                            'env:Header' =>
                                                hash_including(
                                                    'wsse:Security' => hash_including(
                                                        'wsse:BinarySecurityToken' => our_base64_public_key
                                                    )
                                                )
                                        ))
      expect(get_certificate_stub.with(body: body_matcher)).to have_been_requested
    end

    it 'requests the data with the correct digest value in the signature in the header' do
      # Arrange - Build a stub which will record the request for later testing
      recorded_request = nil
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return do |r|
        recorded_request = r
        { body: '', status: 200, headers: { 'Content-Type' => 'application/xml' } }
      end

      # Act - Call the service
      subject.get_certificate('anyid', user_id: "my user id")

      # Assert - Validate the digest
      expect(recorded_request.body).to have_valid_digest_for_acas
    end

    it 'requests the data with the correct signature value in the header' do
      # Arrange - Build a stub which will record the request for later testing
      recorded_request = nil
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return do |r|
        recorded_request = r
        { body: '', status: 200, headers: { 'Content-Type' => 'application/xml' } }
      end

      # Act - Call the service
      subject.get_certificate('anyid', user_id: "my user id")

      # Assert - Validate the signature
      expect(recorded_request.body).to have_valid_signature_for_acas
    end
  end
end
