require 'rails_helper'
RSpec.describe ResponseExportedHandler do
  subject(:handler) { described_class.new }

  let(:example_external_system) { ExternalSystem.find_by(reference: 'ccd_manchester') }
  let(:example_response) { create(:response) }
  let(:mock_event_service) { class_spy EventService }

  it 'creates an export record' do

    # Act - call the handle method
    subject.handle(external_system_id: example_external_system.id, response_id: example_response.id, event_service: mock_event_service)

    # Assert - Check that an export record has been created
    expect(Export.where(external_system_id: example_external_system.id, resource_id: example_response.id, resource_type: 'Response', state: 'created').count).to be 1
  end

  it 'fires the ResponseQueuedForExport event' do
    # Act - call the handle method
    subject.handle(external_system_id: example_external_system.id, response_id: example_response.id, event_service: mock_event_service)

    # Assert - Check that the event was fired
    expect(mock_event_service).to have_received(:publish).with('ResponseQueuedForExport', an_object_having_attributes(external_system_id: example_external_system.id, resource_type: 'Response', resource_id: example_response.id, state: 'created'))
  end
end
