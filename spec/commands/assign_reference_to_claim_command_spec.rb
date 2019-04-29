require 'rails_helper'

RSpec.describe AssignReferenceToClaimCommand do
  subject(:command) { described_class.new(uuid: uuid, data: {}, reference_service: mock_reference_service) }

  let(:uuid) { SecureRandom.uuid }
  let(:root_object) { build(:claim, :example_data, office_code: 32, reference: nil) }
  let(:mock_reference_service) { class_double('ReferenceService', next_number: 20000005) }

  include_context 'with disabled event handlers'

  describe '#apply' do
    context 'using a claim with no reference' do
      it 'adds the reference to the meta' do
        # Arrange
        meta = {}

        # Act
        command.apply(root_object, meta: meta)

        # Assert
        expect(meta).to include reference: '322000000500'
      end
    end

    context 'using a claim with existing reference' do
      let(:root_object) { build(:claim, :example_data, office_code: 32, reference: '222000000200') }
      it 'adds the existing reference to the meta' do
        # Arrange
        meta = {}

        # Act
        command.apply(root_object, meta: meta)

        # Assert
        expect(meta).to include reference: '222000000200'
      end
    end
  end
end
