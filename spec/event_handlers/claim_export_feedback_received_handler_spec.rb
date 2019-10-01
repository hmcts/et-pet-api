require 'rails_helper'
RSpec.describe ClaimExportFeedbackReceivedHandler do
  subject(:handler) { described_class.new }

  it 'adds an event with a status matching that given' do
    # Arrange - Create an example export
    export = create(:export, :claim, :ccd)
    example_data = {
      'export_id' => export.id,
      'sidekiq' => {
        'jid' => 'examplejid'
      },
      'external_data' => {},
      'state' => 'in_progress',
      'percent_complete' => 0
    }

    # Act - call the handler
    handler.handle(example_data.to_json)

    # Assert - Ensure an event has been added
    expect(ExportEvent.where(export: export, state: 'in_progress').count).to be 1
  end

  it 'sets the state to the state given' do
    # Arrange - Create an example export
    export = create(:export, :claim, :ccd)
    example_data = {
      'export_id' => export.id,
      'sidekiq' => {
        'jid' => 'examplejid'
      },
      'external_data' => {},
      'state' => 'in_progress',
      'percent_complete' => 0
    }

    # Act - call the handler
    handler.handle(example_data.to_json)

    # Assert - Ensure an event has been added
    expect(Export.find(export.id).state).to eql "in_progress"
  end

  it 'records the sidekiq jid in the data' do
    # Arrange - Create an example export
    export = create(:export, :claim, :ccd)
    example_data = {
      'export_id' => export.id,
      'sidekiq' => {
        'jid' => 'examplejid'
      },
      'external_data' => {},
      'state' => 'in_progress',
      'percent_complete' => 0
    }

    # Act - call the handler
    handler.handle(example_data.to_json)

    # Assert - Ensure an event has been added
    expect(ExportEvent.where(export: export, state: 'in_progress').first.data['sidekiq']).to include 'jid' => 'examplejid'
  end

  it 'merges the ccd data in the data of the export' do
    # Arrange - Create an example export
    export = create(:export, :claim, :ccd, external_data: { 'test' => 'data' })
    example_data = {
      'export_id' => export.id,
      'sidekiq' => {
        'jid' => 'examplejid'
      },
      'external_data' => {
        'case_id' => 'examplecaseid',
        'case_type_id' => 'examplecasetypeid'
      },
      'state' => 'in_progress',
      'percent_complete' => 0
    }

    # Act - call the handler
    handler.handle(example_data.to_json)

    # Assert - Ensure an event has been added
    expect(Export.find(export.id).external_data).to include 'case_id' => 'examplecaseid', 'case_type_id' => 'examplecasetypeid', 'test' => 'data'
  end
end
