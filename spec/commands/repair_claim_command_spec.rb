require 'rails_helper'

RSpec.describe RepairClaimCommand do
  subject(:command) { described_class.new(event_service: mock_event_service, **data) }

  let(:mock_event_service) { class_spy(EventService) }
  let(:claim_to_repair) { create(:claim, :example_data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_repair_claim_command, claim_id: claim_to_repair.id).as_json }
  let(:root_object) { {} }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'creates a single event (for now) to just start the whole process off' do
      # Act
      command.apply(root_object)

      # Assert
      aggregate_failures "Validating events raised" do
        expect(mock_event_service).to have_received(:publish).with('ClaimCreated', claim_to_repair)
      end
    end

  end

  describe '#valid?' do

    context 'with a claim id that does not exist' do
      let(:data) { build(:json_repair_claim_command, claim_id: -1).as_json }

      it 'is false' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the claim_ids attribute' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:claim_id]).to include(error: :claim_not_found, claim_id: -1, uuid: command.uuid, command: 'RepairClaim')
      end
    end

    context 'with all valid data' do
      let(:data) { build(:json_repair_claim_command, claim_id: claim_to_repair.id).as_json }

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end
  end
end
