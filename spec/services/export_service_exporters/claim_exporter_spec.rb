require 'rails_helper'
RSpec.describe ExportServiceExporters::ClaimExporter do
  describe '#export' do
    context 'with claim that has claimant with non alpha numerics in name' do
      subject(:exporter) { described_class.new }

      let(:claimants) { build_list(:claimant, 1, :mr_na_o_malley) }
      let(:claim) { build(:claim, :with_pdf_file, :with_xml_file, :with_text_file, number_of_claimants: 0, claimants: claimants) }

      # Create an export record to allow the claim to be found
      before do
        Export.create resource: claim
      end

      it 'exports a pdf file with the correct name' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          expect(File.exist?(File.join(dir, "#{claim.reference}_ET1_na_OMalley.pdf"))).to be true
        end
      end

      it 'exports a txt file with the correct name' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          expect(File.exist?(File.join(dir, "#{claim.reference}_ET1_na_OMalley.txt"))).to be true
        end
      end

      it 'exports an xml file with the correct name' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          expect(File.exist?(File.join(dir, "#{claim.reference}_ET1_na_OMalley.xml"))).to be true
        end
      end
    end
  end
end
