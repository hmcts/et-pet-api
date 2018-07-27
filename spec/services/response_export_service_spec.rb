require 'rails_helper'
RSpec.describe ResponseExportService do
  subject(:service) { described_class.new(response) }

  let(:response) { create(:response, :example_data, :with_pdf_file, :with_text_file, :with_rtf_file) }

  describe 'to_be_exported' do
    it 'marks the response as ready to be exported' do
      expect { service.to_be_exported }.to change(Export.responses, :count).by(1)
    end
  end

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

  describe 'export_rtf' do
    it 'returns an rtf file which happens to be the original' do
      result = service.export_rtf
      expect(result).to have_attributes filename: 'et3_atos_export.rtf'
    end
  end
end
