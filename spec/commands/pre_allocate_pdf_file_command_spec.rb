require 'rails_helper'

RSpec.describe PreAllocatePdfFileCommand do
  subject(:command) { described_class.new(uuid: uuid, data: {}, allocator_service: mock_allocator_service) }

  let(:uuid) { SecureRandom.uuid }
  let(:root_object) { build(:claim) }
  let(:mock_allocator_service) { instance_double(UploadedFileAllocatorService, allocate: nil, allocated_url: 'http://mocked.com/allocated') }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'adds a pdf_url to the meta' do
      # Arrange
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include pdf_url: 'http://mocked.com/allocated'
    end

    it 'uses the correct filename when calling the allocator' do
      # Arrange
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      claimant = root_object.primary_claimant
      fn = "et1_#{claimant.first_name.downcase}_#{claimant.last_name.downcase}.pdf"
      expect(mock_allocator_service).to have_received(:allocate).with(fn, anything)
    end
  end
end
