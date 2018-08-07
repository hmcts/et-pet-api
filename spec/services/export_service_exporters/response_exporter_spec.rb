require 'rails_helper'
RSpec.describe ExportServiceExporters::ResponseExporter do
  describe '#export' do
    context 'with response that has claimant with non alpha numerics in name' do
      subject(:exporter) { described_class.new }

      let(:respondent) { build(:respondent, :mr_na_o_malley) }
      let(:response) { build(:response, :with_pdf_file, :with_text_file, :with_rtf_file, respondent: respondent) }

      # Create an export record to allow the claim to be found
      before do
        Export.create resource: response
      end

      it 'exports a pdf file with the correct name' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          expect(File.exist?(File.join(dir, "#{response.reference}_ET3_na_omalley.pdf"))).to be true
        end
      end

      it 'exports a txt file with the correct name' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          expect(File.exist?(File.join(dir, "#{response.reference}_ET3_na_omalley.txt"))).to be true
        end
      end

      it 'exports an xml file with the correct name' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          expect(File.exist?(File.join(dir, "#{response.reference}_ET3_Attachment_na_omalley.rtf"))).to be true
        end
      end
    end
  end
end
