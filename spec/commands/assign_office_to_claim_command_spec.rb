require 'rails_helper'

RSpec.describe AssignOfficeToClaimCommand do
  subject(:command) { described_class.new(uuid: uuid, data: {}, office_service: mock_office_service) }

  let(:uuid) { SecureRandom.uuid }
  let(:root_object) { build(:claim, :example_data) }
  let(:example_office) { instance_double('Office', code: 65, name: 'Example Office', telephone: '01234 567890', address: '1 Liverpool Street', email: 'info@exampleoffice.com') }
  let(:mock_office_service) { class_double('OfficeService', lookup_postcode: example_office) }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'adds the office data to the meta' do
      # Arrange
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include office: a_hash_including(code: 65, name: 'Example Office', telephone: '01234 567890', address: '1 Liverpool Street', email: 'info@exampleoffice.com')
    end
  end
end
