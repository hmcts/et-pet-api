require 'rails_helper'
RSpec.describe EtAcasApi::V2::AcasApiService do
  subject(:api) { described_class.new(logger: logger, service_url: example_get_certificate_url, subscription_key: example_subscription_key) }
  let(:collection) { [] }
  let(:logger) { instance_spy('ActiveSupport::Logger') }
  # Common Setup - The url to the service
  let(:example_get_certificate_url) { 'https://localhost/ECCLJson' }
  let(:example_subscription_key) { 'examplesubscriptionkey' }

  describe '#get_certificate' do
    it 'requests the data from the endpoint' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: [build(:json_valid_acas_response, :valid)].to_json, status: 200, headers: { 'Content-Type' => 'application/json' }
      subject.call(['anyid'], user_id: "my user id", into: collection)
      expect(get_certificate_stub).to have_been_requested
    end

    it 'requests the data with the correct certificate number and user id' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: [build(:json_valid_acas_response, :valid)].to_json, status: 200, headers: { 'Content-Type' => 'application/json' }
      subject.call(['anyid'], user_id: "my user id", into: collection)
      body_matcher = hash_including('CertificateNumbers' => array_including('anyid'))
      expect(get_certificate_stub.with(body: body_matcher)).to have_been_requested
    end

    it 'requests the data with the correct security token in the signature in the header' do
      get_certificate_stub = stub_request(:post, example_get_certificate_url).to_return body: [build(:json_valid_acas_response, :valid)].to_json, status: 200, headers: { 'Content-Type' => 'application/json' }
      subject.call(['anyid'], user_id: "my user id", into: collection)
      expect(get_certificate_stub.with(headers: { 'Ocp-Apim-Subscription-Key' => example_subscription_key })).to have_been_requested
    end

    it 'requests the data and handles a positive response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:json_valid_acas_response, :valid)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/json' },
                                                                 body: [response_factory].to_json

      # Act - Call the service
      subject.call(['anyid'], user_id: "my user id", into: collection)

      # Assert - Validate the certificate
      certificate = collection.first
      aggregate_failures 'Validate all non file attributes are correct' do
        expect(certificate.certificate_number).to eql response_factory.certificate_number
        expect(certificate.certificate_base64).to eql Base64.encode64(File.read(response_factory.certificate_file))
      end
    end


    it 'requests the data and sets status to :found with a positive response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:soap_valid_acas_response, :valid)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/json' },
                                                                 body: [response_factory].to_json

      # Act - Call the service
      subject.call(['anyid'], user_id: "my user id", into: collection)
      # Assert - Validate the certificate
      expect(subject.status).to be :found
    end

    it 'requests the data and handles a not found response' do
      # Arrange - Build a stub which responds with the correct body
      responses_factory = build(:json_valid_acas_responses, traits: :not_found, count: 1)
      stub_request(:post, example_get_certificate_url).to_return status: 200,
                                                                 headers: { 'Content-Type' => 'application/json' },
                                                                 body: responses_factory.to_json

      # Act - Call the service
      subject.call(['anyid'], user_id: "my user id", into: collection)

      # Assert - Validate that the status is correct and the certificate is nil
      aggregate_failures 'Validate status and certificate' do
        expect(subject.status).to be :not_found
      end
    end

    it 'requests the data and handles an acas server error response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:json_valid_acas_response, :acas_server_error)
      stub_request(:post, example_get_certificate_url).to_return status: 500,
                                                                 headers: { 'Content-Type' => 'application/json' },
                                                                 body: response_factory.to_json

      # Act - Call the service
      subject.call(['anyid'], user_id: "my user id", into: collection)

      # Assert - Validate that the status is correct and the certificate is nil
      aggregate_failures 'Validate status and certificate' do
        expect(subject.status).to be :acas_server_error
        expect(subject.errors).to include base: a_collection_including('An error occured in the ACAS service')
      end
    end

    it 'requests the data and logs an acas server error response' do
      # Arrange - Build a stub which responds with the correct body
      response_factory = build(:json_valid_acas_response, :acas_server_error)
      stub_request(:post, example_get_certificate_url).to_return status: 500,
                                                                 headers: { 'Content-Type' => 'application/json' },
                                                                 body: response_factory.to_json

      # Act - Call the service
      subject.call(['anyid'], user_id: "my user id", into: collection)

      # Assert - Validate that the status is correct and the certificate is nil
      expect(logger).to have_received(:warn).with("An error occured in the ACAS server when trying to find certificates 'anyid' - the error reported was '#{response_factory.message}'")
    end

    it 'requests the data and handles a timeout response' do
      # Arrange - Build a stub which responds with a timeout for the service request
      stub_request(:post, example_get_certificate_url).to_timeout

      # Act - Call the service
      subject.call(['anyid'], user_id: "my user id", into: collection)

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
      subject.call(['anyid'], user_id: "my user id", into: collection)

      # Assert - Validate that the status is correct and the certificate is nil
      expect(logger).to have_received(:warn).with("An error occured connecting to the ACAS server when trying to find certificates 'anyid' - the error reported was 'execution expired'")
    end
  end
end
