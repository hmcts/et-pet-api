require 'rails_helper'

RSpec.describe ClaimsExportJob do
  describe '#perform' do
    subject(:job) { described_class.new(claims_export_service: export_service_instance) }

    let(:export_service_instance) { instance_spy('::EtAtosExport::ExportService') }

    it 'delegates its work to the injected ExportService' do
      # Act
      job.perform

      # Assert
      expect(export_service_instance).to have_received(:export)
    end

    it 'defaults to using the ExportService if not injected' do
      # Arrange
      export_service_class = class_spy('::EtAtosExport::ExportService', new: export_service_instance).as_stubbed_const
      job = described_class.new

      # Act
      job.perform

      # Assert
      expect(export_service_class).to have_received(:new)
    end
  end
end
