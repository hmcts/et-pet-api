require 'rails_helper'
RSpec.describe ClaimManuallyAssignedHandler do
  subject(:handler) { described_class.new }
  let!(:example_external_system) { ExternalSystem.find_by_reference('ccd_manchester') }
  let!(:second_example_external_system) { create(:external_system, :atos, reference: 'atos_temp', office_codes: [24], export_claims: true) }
  let(:example_claim) { create(:claim, office_code: 24) }
  let(:mock_event_service) { class_spy EventService }

  it 'creates an export record' do

    # Act - call the handle method
    subject.handle(claim: example_claim, event_service: mock_event_service)

    # Assert - Check that an export record has been created
    expect(mock_event_service).to have_received(:publish).with('ClaimExported', external_system_id: example_external_system.id, claim_id: example_claim.id)
  end

  it 'creates an export record for the second external system' do

    # Act - call the handle method
    subject.handle(claim: example_claim, event_service: mock_event_service)

    # Assert - Check that an export record has been created
    expect(mock_event_service).to have_received(:publish).with('ClaimExported', external_system_id: second_example_external_system.id, claim_id: example_claim.id)

  end
end
