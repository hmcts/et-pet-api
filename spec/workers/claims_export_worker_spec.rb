require 'rails_helper'

RSpec.describe ClaimsExportWorker do
  describe '#perform' do
    subject(:worker) { described_class.new(claims_export_service: export_service_instance) }

    let(:export_service_instance) { instance_spy('ClaimsExportService') }

    it 'delegates its work to the injected ClaimsExportService' do
      # Act
      worker.perform

      # Assert
      expect(export_service_instance).to have_received(:export)
    end

    it 'defaults to using the ClaimsExportService if not injected' do
      # Arrange
      export_service_class = class_spy('ClaimsExportService', new: export_service_instance).as_stubbed_const
      worker = described_class.new

      # Act
      worker.perform

      # Assert
      expect(export_service_class).to have_received(:new)
    end
  end
end
