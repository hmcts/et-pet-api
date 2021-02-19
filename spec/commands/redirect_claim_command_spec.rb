require 'rails_helper'

RSpec.describe RedirectClaimCommand do
  subject(:command) { described_class.new(event_service: mock_event_service, **data) }
  let(:mock_event_service) { class_spy(EventService) }
  let(:example_claim) { create(:claim) }
  let(:new_office) { Office.find_by_code(24) }
  let(:new_office_external_system) { ExternalSystem.containing_office_code(new_office.code).exporting_claims.first }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_redirect_claim_command, office_id: new_office.id, claim_id: example_claim.id).as_json }
  let(:root_object) { {} }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'creates 1 event to create the export and schedule the communication' do
      # Act
      command.apply(root_object)

      # Assert
      aggregate_failures "Validating events raised" do
        expect(mock_event_service).to have_received(:publish).with('ClaimExported', external_system_id: new_office_external_system.id, claim_id: example_claim.id)
      end
    end

    it 'changes the claims office' do
      # Act
      command.apply(root_object)

      # Assert
      expect(example_claim.reload.office).to eq new_office
    end

  end

  describe '#valid?' do

    context 'with a claim id that does not exist' do
      let(:data) { build(:json_redirect_claim_command, claim_id: -1, office_id: new_office.id).as_json }

      it 'is false' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the claim_id attribute' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:claim_id]).to include(error: :claim_not_found, claim_id: -1, uuid: command.uuid, command: 'RedirectClaim')
      end
    end

    context 'with all valid data' do
      let(:data) { build(:json_redirect_claim_command, claim_id: example_claim.id, office_id: new_office.id).as_json }

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end

    context 'with invalid office_id' do
      let(:data) { build(:json_redirect_claim_command, claim_id: example_claim.id, office_id: -1).as_json }

      it 'contains the correct error key in the office_id attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:office_id]).to include(error: :office_not_found, office_id: -1, uuid: command.uuid, command: 'RedirectClaim')
      end
    end
  end
end
