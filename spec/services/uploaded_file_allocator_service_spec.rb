require 'rails_helper'
RSpec.describe UploadedFileAllocatorService do
  subject(:service) { described_class.new }
  let(:response) { build(:response) }

  describe '#allocate' do
    it 'allocates a file to the collection with an empty blob' do
      # Act
      service.allocate('test.pdf', into: response)

      # Assert
      expect(response.pre_allocated_file_keys.detect { |k| k.filename == 'test.pdf' }).to be_present
    end
  end

  describe '#allocated_url' do
    context 'using s3 storage' do
      include_context 'with cloud provider switching', cloud_provider: :amazon
      it 'returns the url of the allocated file on s3' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get the url
        result = service.allocated_url

        # Assert - make sure it is a url
        expect(result).to be_a_valid_url
      end

      it 'returns a url that will 404 if requested' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get from the url
        result = HTTParty.get service.allocated_url

        # Assert - make sure the response is a 404 when requested
        expect(result.code).to be 404
      end

      it 'returns a url which will expire in 1 hour' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get the url
        result = service.allocated_url

        # Assert - make sure it is a url
        query = Rack::Utils.parse_nested_query(URI.parse(result).query)
        expect(query).to include 'X-Amz-Expires' => '3600'
      end

      it 'returns a minio test server url as we are in test mode' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get the url
        result = service.allocated_url

        expect(result).to start_with(ActiveStorage::Blob.service.bucket.url)
      end
    end
    context 'using azure storage' do
      include_context 'with cloud provider switching', cloud_provider: :azure
      it 'returns the url of the allocated file on azure' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get the url
        result = service.allocated_url

        # Assert - make sure it is a url
        expect(result).to be_a_valid_url
      end

      it 'returns a url that will 404 if requested' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get from the url
        result = HTTParty.get service.allocated_url

        # Assert - make sure the response is a 404 when requested
        expect(result.code).to be 404
      end

      it 'returns a url which will expire in 1 hour' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get the url
        result = service.allocated_url

        # Assert - make sure it is a url
        query = Rack::Utils.parse_nested_query(URI.parse(result).query)
        expiry = Time.zone.parse(query['se']).utc
        expect(expiry - Time.zone.now.utc).to be_between(3590, 3600)
      end

      it 'returns an azurite test server url as we are in test mode' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response)

        # Act - get the url
        result = service.allocated_url

        expect(result).to start_with("#{ActiveStorage::Blob.service.blobs.generate_uri}/#{ActiveStorage::Blob.service.container}")
      end
    end
  end
end
