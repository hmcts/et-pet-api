require 'rails_helper'
RSpec.describe ClaimExportHandler do
  subject(:handler) { described_class.new }

  describe '#handle' do
    mock_handler_calls = []
    let(:mock_handler_class) do
      Class.new do
        define_method :handle do |args|
          mock_handler_calls << args
        end
      end
    end

    before do
      ExternalSystem.destroy_all
      EventService.instance.subscribe('ClaimQueuedForExport', mock_handler_class, async: false, in_process: true)
    end

    after do
      EventService.instance.unsubscribe('ClaimQueuedForExport', mock_handler_class)
    end

    let!(:system1) { create(:external_system, :minimal, office_codes: Office.pluck(:code)[0..9]) }
    let!(:system2) { create(:external_system, :minimal, office_codes: Office.pluck(:code)[9..14]) }
    let!(:system3) { create(:external_system, :minimal, office_codes: Office.pluck(:code)[15..-1]) }

    it 'creates an export record for every external system with matching office code'

    it 'fires a ClaimQueuedForExport event for every external system with matching office code' do
      # Arrange - create a claim in the overlap area between system1 and system2
      claim = create(:claim, office_code: system1.office_codes.last)

      # Act
      handler.handle(claim)

      # Assert
      aggregate_failures 'check correct handler calls have been made' do
        expect(mock_handler_calls[0]).to have_attributes(external_system_id: system1.id, resource_id: claim.id).and(be_an_instance_of(Export))
        expect(mock_handler_calls[1]).to have_attributes(external_system_id: system2.id, resource_id: claim.id).and(be_an_instance_of(Export))
        expect(mock_handler_calls.length).to be 2
      end
    end

  end
end
