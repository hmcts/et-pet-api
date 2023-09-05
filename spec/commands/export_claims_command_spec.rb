require 'rails_helper'

RSpec.describe ExportClaimsCommand do
  subject(:command) { described_class.new(event_service: mock_event_service, **data) }

  let(:mock_event_service) { class_spy(EventService) }
  let(:example_external_system_reference) { "ccd_manchester" }
  let(:example_claims) { create_list(:claim, 3) }
  let(:example_external_system) { ExternalSystem.find_by!(reference: example_external_system_reference) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_export_claims_command, external_system_id: example_external_system.id, claim_ids: example_claims.map(&:id)).as_json }
  let(:root_object) { {} }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'creates 3 separate events to create the export and schedule the communication' do
      # Act
      command.apply(root_object)

      # Assert
      aggregate_failures "Validating events raised" do
        expect(mock_event_service).to have_received(:publish).with('ClaimExported', external_system_id: example_external_system.id, claim_id: example_claims[0].id)
        expect(mock_event_service).to have_received(:publish).with('ClaimExported', external_system_id: example_external_system.id, claim_id: example_claims[1].id)
        expect(mock_event_service).to have_received(:publish).with('ClaimExported', external_system_id: example_external_system.id, claim_id: example_claims[2].id)
      end
    end

  end

  describe '#valid?' do

    context 'with a claim id that does not exist' do
      let(:data) { build(:json_export_claims_command, claim_ids: example_claims.map(&:id) + [-1], external_system_id: example_external_system.id).as_json }

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
        expect(command.errors.details[:claim_ids]).to include(error: :claim_not_found, claim_id: -1, uuid: command.uuid, command: 'ExportClaims')
      end
    end

    context 'with all valid data' do
      let(:data) { build(:json_export_claims_command, claim_ids: example_claims.map(&:id), external_system_id: example_external_system.id).as_json }

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end

    context 'with invalid external_system_id' do
      let(:data) { build(:json_export_claims_command, claim_ids: example_claims.map(&:id), external_system_id: -1).as_json }

      it 'contains the correct error key in the external_system_id attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:external_system_id]).to include(error: :external_system_not_found, external_system_id: -1, uuid: command.uuid, command: 'ExportClaims')
      end
    end
  end
end
