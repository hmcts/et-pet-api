require 'rails_helper'
RSpec.describe EtAtosExport::ResponseExportService do
  subject(:service) { described_class.new(response) }

  let(:response) { create(:response, :example_data, :with_pdf_file, :with_text_file, :with_rtf_file) }

  describe 'export_pdf' do
    it 'returns the pdf file' do
      result = service.export_pdf
      expect(result).to have_attributes filename: 'et3_atos_export.pdf'
    end
  end

  describe 'export_txt' do
    it 'returns the txt file saved with the response' do
      result = service.export_txt
      expect(result).to have_attributes filename: 'et3_atos_export.txt'
    end
  end

  describe 'export_additional_information' do
    it 'returns an additional information file which is based on the original rtf' do
      result = service.export_additional_information_file
      expect(result).to have_attributes filename: 'et3_atos_export_additional_information.pdf'
    end
  end
end
