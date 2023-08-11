require 'rails_helper'

RSpec.describe ResponseExportFeedbackReceivedHandler do
  it 'updates the office of the response' do
    export = create(:export, :ccd, :response)
    event_data = {
      'export_id' => export.id,
      'sidekiq' => { 'some' => 'thing' },
      'external_data' => {
        'case_id' => 'doesntmatter',
        'case_reference' => export.resource.case_number,
        'case_type_id' => 'Manchester',
        'office' => 'Manchester'
      },
      'state' => 'complete'
    }
    described_class.new.handle(event_data.to_json)
    expect(export.resource.reload.office.name).to eq('Manchester')
  end

  it 'does not update the office of the response if the office is not found' do
    export = create(:export, :ccd, :response)
    event_data = {
      'export_id' => export.id,
      'sidekiq' => { 'some' => 'thing' },
      'external_data' => {
        'case_id' => 'doesntmatter',
        'case_reference' => export.resource.case_number,
        'case_type_id' => 'Manchester',
        'office' => nil
      },
      'state' => 'complete'
    }
    expect { described_class.new.handle(event_data.to_json) }.not_to(change { export.reload.resource.office })
  end

  it 'does not update the office of the response if the office name does not exist' do
    export = create(:export, :ccd, :response)
    event_data = {
      'export_id' => export.id,
      'sidekiq' => { 'some' => 'thing' },
      'external_data' => {
        'case_id' => 'doesntmatter',
        'case_reference' => export.resource.case_number,
        'case_type_id' => 'Manchester',
        'office' => 'does not exist'
      },
      'state' => 'complete'
    }
    expect { described_class.new.handle(event_data.to_json) }.not_to(change { export.reload.resource.office })
  end
end
