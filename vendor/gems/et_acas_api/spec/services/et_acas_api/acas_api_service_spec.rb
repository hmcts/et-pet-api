require 'rails_helper'
RSpec.describe EtAcasApi::AcasApiService do
  subject(:api) { described_class.new config }
  let(:our_certificate_path) { File.absolute_path(File.join('..', '..', 'acas_interface_support', 'x509', 'ours', 'publickey.cer'), __dir__) }
  let(:our_private_key_path) { File.absolute_path(File.join('..', '..', 'acas_interface_support', 'x509', 'ours', 'privatekey.pem'), __dir__) }
  let(:our_certificate) { OpenSSL::X509::Certificate.new(File.read(our_certificate_path)) }
  let(:our_base64_public_key) { Base64.encode64(our_certificate.to_der).tr("\n", '') }
  let(:config) { {
      wsdl_url: 'http://mydomain.com/my.wsdl',
      current_time: Time.zone.parse('31/12/2017 18:00:00'),
      acas_rsa_certificate_path: File.absolute_path(File.join('..', '..', 'acas_interface_support', 'x509', 'theirs', 'publickey.cer'), __dir__),
      rsa_certificate_path: our_certificate_path,
      rsa_private_key_path: our_private_key_path
  } }
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

      # Assert - Stage 1 - Calculate the expected digest value which uses nokokiri to canonicalize it correctly
      doc = Nokogiri::XML(recorded_request.body)
      node = doc.xpath('//env:Envelope/env:Header/wsse:Security/wsu:Timestamp', doc.collect_namespaces).first
      digest_value = Base64.encode64(OpenSSL::Digest::SHA1.digest(node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0))).strip

      # Assert - Stage 2 - Test the digest value is correct
      xml = Hash.from_xml(recorded_request.body)
      expect(xml.dig('Envelope', 'Header', 'Security', 'Signature', 'SignedInfo', 'Reference', 'DigestValue')).to eql digest_value
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

      # Assert - Stage 1 - Calculate the expected signature value which uses nokokiri to canonicalize it correctly
      doc = Nokogiri::XML(recorded_request.body)
      ns = doc.collect_namespaces
      ns['xmlns:ds'] = ns.delete('xmlns')
      signed_info_node = doc.xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignedInfo', ns).first
      signature_value_node = doc.xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignatureValue', ns).first
      signature_value = Base64.decode64(signature_value_node.text)
      #certs.private_key.sign(OpenSSL::Digest::SHA1.new, node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0))
      document = signed_info_node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      expect(our_certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature_value, document)).to be true

    end
  end
end
