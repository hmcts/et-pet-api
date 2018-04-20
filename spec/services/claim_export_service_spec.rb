require 'rails_helper'
RSpec.describe ClaimExportService do
  subject(:service) { described_class.new(claim) }

  let(:landing_folder) { Rails.root.join('tmp', 'storage', 'app', 'landing_folder') }
  let(:claim) { create(:claim, :with_pdf_file, :with_xml_file) }

  describe 'to_be_exported' do
    it 'marks the claim as ready to be exported' do
      expect { service.to_be_exported }.to change(ClaimExport, :count).by(1)
    end
  end

  describe 'export_pdf' do
    it 'returns a pdf file which happens to be the original' do
      result = service.export_pdf
      expect(result).to eql claim.pdf_file
    end
  end

  describe 'export_xml' do
    it 'returns the xml file saved with the claim' do
      result = service.export_xml
      expect(result).to have_attributes filename: 'et1_first_last.xml'
    end
  end
end
