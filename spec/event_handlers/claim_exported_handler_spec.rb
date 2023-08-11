require 'rails_helper'
RSpec.describe ClaimExportedHandler do
  subject(:handler) { described_class.new }

  let(:example_external_system) { ExternalSystem.find_by_reference('ccd_manchester') }
  let(:example_claim) { create(:claim) }
  let(:mock_event_service) { class_spy EventService }

  it 'creates an export record' do

    # Act - call the handle method
    subject.handle(external_system_id: example_external_system.id, claim_id: example_claim.id, event_service: mock_event_service)

    # Assert - Check that an export record has been created
    expect(Export.where(external_system_id: example_external_system.id, resource_id: example_claim.id, resource_type: 'Claim', state: 'created').count).to be 1
  end

  it 'fires the ClaimQueuedForExport event' do
    # Act - call the handle method
    subject.handle(external_system_id: example_external_system.id, claim_id: example_claim.id, event_service: mock_event_service)

    # Assert - Check that the event was fired
    expect(mock_event_service).to have_received(:publish).with('ClaimQueuedForExport', an_object_having_attributes(external_system_id: example_external_system.id, resource_type: 'Claim', resource_id: example_claim.id, state: 'created'))
  end
end
