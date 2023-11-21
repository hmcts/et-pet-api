require 'rails_helper'
RSpec.describe UploadedFileAllocatorService do
  subject(:service) { described_class.new }

  let(:response_object) { build(:response) }

  around do |example|
    ActiveStorage::Current.set(url_options: { host: 'www.example.com' }) do
      example.run
    end
  end

  describe '#allocate' do
    it 'allocates a file to the collection with an empty blob' do
      # Act
      service.allocate('test.pdf', into: response_object)

      # Assert
      expect(response_object.pre_allocated_file_keys.detect { |k| k.filename == 'test.pdf' }).to be_present
    end
  end

  describe '#allocated_url' do
    include ActionDispatch::Integration::Runner
    def app
      ::Rails.application
    end
    context 'with azure storage' do
      include_context 'with local storage'
      it 'returns the url of the allocated file on azure' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response_object)

        # Act - get the url
        result = service.allocated_url

        # Assert - make sure it is a url
        expect(result).to be_a_valid_url
      end

      it 'returns a url that will 404 if requested' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response_object)

        # Act - get from the url
        get service.allocated_url

        # Assert - make sure the response is a 404 when requested
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a rails url to access the blob' do
        # Arrange - Allocate a file
        service.allocate('test.pdf', into: response_object)

        # Act - get the url
        result = service.allocated_url

        expect(result).to start_with("/api/v2/blobs/")
      end
    end
  end
end
