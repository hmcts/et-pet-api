require 'rails_helper'

RSpec.describe ClaimsExportWorker do
  describe '#perform' do
    subject(:worker) { described_class.new(claims_export_service: export_service_instance) }

    let(:export_service_instance) { instance_spy('ExportService') }

    it 'delegates its work to the injected ExportService' do
      # Act
      worker.perform

      # Assert
      expect(export_service_instance).to have_received(:export)
    end

    it 'defaults to using the ExportService if not injected' do
      # Arrange
      export_service_class = class_spy('ExportService', new: export_service_instance).as_stubbed_const
      worker = described_class.new

      # Act
      worker.perform

      # Assert
      expect(export_service_class).to have_received(:new)
    end
  end
end
