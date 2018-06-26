require 'rails_helper'
RSpec.describe UploadedFileAllocatorService do
  let(:response) { build(:response) }
  subject(:service) { described_class.new }

  describe '#allocate' do
    it 'allocates a file to the collection with an empty blob' do
      # Act
      service.allocate('test.pdf', into: response)

      # Assert
      expect(response.pre_allocated_file_keys.detect { |k| k.filename == 'test.pdf' }).to be_present
    end
  end

  describe '#allocated_url' do
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
  end
end
