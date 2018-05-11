require 'rails_helper'
RSpec.describe ClaimExportService do
  subject(:service) { described_class.new(claim) }

  let(:claim) { create(:claim, :with_pdf_file, :with_xml_file, :with_text_file, :with_claimants_text_file, :with_claimants_csv_file, :with_rtf_file) }

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

  describe 'export_txt' do
    it 'returns the txt file saved with the claim' do
      result = service.export_txt
      expect(result).to have_attributes filename: 'et1_first_last.txt'
    end
  end

  describe 'export_rtf' do
    it 'returns an rtf file which happens to be the original' do
      result = service.export_rtf
      expect(result).to have_attributes filename: 'et1_attachment_first_last.rtf'
    end
  end

  describe 'export_claimants_txt' do
    it 'returns the claimants txt (ET1a) file saved with the claim' do
      result = service.export_claimants_txt
      expect(result).to have_attributes filename: 'et1a_first_last.txt'
    end
  end

  describe 'export_claimants_csv' do
    it 'returns a csv file which happens to be the original' do
      result = service.export_claimants_csv
      expect(result).to have_attributes filename: 'et1a_first_last.csv'
    end
  end
end
