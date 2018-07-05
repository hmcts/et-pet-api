require 'rails_helper'
RSpec.describe EtAcasApi::AcasApiService do
  subject(:api) { described_class.new(logger: logger) }
  let(:certificate) { EtAcasApi::Certificate.new }
  let(:logger) { instance_spy('ActiveSupport::Logger') }
  let(:rsa_certificate_contents) { Rails.configuration.et_acas_api.rsa_certificate }
  # Common Setup - The url to the service which should match that in spec/acas_interface_support/wsdl.txt
  let(:example_get_certificate_url) { "https://localhost/Lookup/ECService.svc" }

  describe '#get_certificate' do
    it 'requests the data from the correct entry in the wsdl' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' }
      subject.call('anyid', user_id: "my user id", into: certificate)
      expect(get_certificate_stub).to have_been_requested
    end

    it 'requests the data with the correct certificate number and user id' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' }
      subject.call('anyid', user_id: "my user id", into: certificate)
      body_matcher = hash_including('env:Envelope' =>
                                      hash_including('env:Body' =>
                                                       hash_including('tns:GetECCertificate' =>
                                                                        hash_including(
                                                                          'tns:request' =>
                                                                            hash_including(
                                                                              'ins0:ECCertificateNumber' => equals_encrypted_param_for_acas('anyid'),
                                                                              'ins0:UserId' => equals_encrypted_param_for_acas('my user id')
                                                                            )
                                                                        ))))
      expect(get_certificate_stub.with(body: body_matcher)).to have_been_requested
    end

    it 'requests the data with the correct current time' do
      # Arrange - provide a stub to return valid data
      recorded_request = nil
      stub_request(:post, example_get_certificate_url).to_return do |r|
        recorded_request = r
        { body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' } }
      end

      # Act - Make the call

      subject.call('anyid', user_id: "my user id", into: certificate)
      # Assert - Check the correct date was used
      expect(recorded_request.body).to have_valid_current_date_time_for_acas
    end


    it 'requests the data with the correct security token in the signature in the header' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' }
      subject.call('anyid', user_id: "my user id", into: certificate)
      our_base64_public_key = Base64.encode64(OpenSSL::X509::Certificate.new(rsa_certificate_contents).to_der).tr("\n", '')
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
      stub_request(:post, example_get_certificate_url).to_return do |r|
        recorded_request = r
        { body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' } }
      end

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate the digest
      expect(recorded_request.body).to have_valid_digest_for_acas
    end

    it 'requests the data with the correct signature value in the header' do
      # Arrange - Build a stub which will record the request for later testing
      recorded_request = nil
      stub_request(:post, example_get_certificate_url).to_return do |r|
        recorded_request = r
        { body: build(:soap_valid_acas_response, :valid).to_xml, status: 200, headers: { 'Content-Type' => 'application/xml' } }
      end

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate the signature
      expect(recorded_request.body).to have_valid_signature_for_acas
    end

    it 'requests the data and handles a positive response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :valid)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/xml' },
                                                                 body: response_factory.to_xml

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate the signature
      aggregate_failures 'Validate all non file attributes are correct' do
        expect(certificate.claimant_name).to eql response_factory.claimant_name
        expect(certificate.date_of_issue).to eql response_factory.date_of_issue
        expect(certificate.date_of_receipt).to eql response_factory.date_of_receipt
        expect(certificate.certificate_number).to eql response_factory.certificate_number
        expect(certificate.message).to eql response_factory.message
        expect(certificate.method_of_issue).to eql response_factory.method_of_issue
        expect(certificate.respondent_name).to eql response_factory.respondent_name
        expect(certificate.certificate_base64).to eql Base64.encode64(File.read(response_factory.certificate_file))
      end
    end


    it 'requests the data and sets status to :found with a positive response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :valid)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/xml' },
                                                                 body: response_factory.to_xml

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)
      certificate
      # Assert - Validate the signature
      expect(subject.status).to be :found
    end

    it 'requests the data and handles a not found response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :not_found)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/xml' },
                                                                 body: response_factory.to_xml

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate that the status is correct and the certificate is nil
      aggregate_failures 'Validate status and certificate' do
        expect(subject.status).to be :not_found
      end
    end

    it 'requests the data and handles an invalid certificate response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :invalid_certificate_format)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/xml' },
                                                                 body: response_factory.to_xml

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate that the status is correct and the certificate is nil
      aggregate_failures 'Validate status and certificate' do
        expect(subject.status).to be :invalid_certificate_format
        expect(subject.errors).to include id: a_collection_including('Invalid certificate format')
      end
    end

    it 'requests the data and handles an acas server error response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :acas_server_error)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/xml' },
                                                                 body: response_factory.to_xml

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate that the status is correct and the certificate is nil
      aggregate_failures 'Validate status and certificate' do
        expect(subject.status).to be :acas_server_error
        expect(subject.errors).to include base: a_collection_including('An error occured in the ACAS service')
      end
    end

    it 'requests the data and logs an acas server error response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :acas_server_error)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/xml' },
                                                                 body: response_factory.to_xml

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate that the status is correct and the certificate is nil
      expect(logger).to have_received(:warn).with("An error occured in the ACAS server when trying to find certificate 'anyid' - the error reported was '#{response_factory.message}'")
    end

    it 'requests the data and handles a timeout response' do
      # Arrange - Build a stub which responds with a timeout for the service request
      stub_request(:post, example_get_certificate_url).to_timeout

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate that the status is correct and the certificate is nil
      aggregate_failures 'Validate status and certificate' do
        expect(subject.status).to be :acas_server_error
        expect(subject.errors).to include base: a_collection_including('An error occured connecting to the ACAS service')
      end
    end

    it 'requests the data and logs a timeout response' do
      # Arrange - Build a stub which responds with a timeout for the service request
      stub_request(:post, example_get_certificate_url).to_timeout

      # Act - Call the service
      subject.call('anyid', user_id: "my user id", into: certificate)

      # Assert - Validate that the status is correct and the certificate is nil
      expect(logger).to have_received(:warn).with("An error occured connecting to the ACAS server when trying to find certificate 'anyid' - the error reported was 'execution expired'")
    end
  end
end
