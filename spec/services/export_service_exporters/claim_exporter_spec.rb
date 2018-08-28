require 'rails_helper'
RSpec.describe ExportServiceExporters::ClaimExporter do
  describe '#export' do
    context 'with claim that has claimant with non alpha numerics in name' do
      subject(:exporter) { described_class.new }

      let(:claim_claimants) { build_list(:claim_claimant, 1, :mr_na_o_malley) }
      let(:claim) { build(:claim, :with_pdf_file, :with_text_file, number_of_claimants: 0, claim_claimants: claim_claimants) }

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
    end

    context 'with claim that has claimant with non alpha numerics in name and an underscore' do
      subject(:exporter) { described_class.new }

      let(:claim_claimants) { build_list(:claim_claimant, 1, claimant: build(:claimant, :mr_na_o_malley, last_name: "_O'Malley"), primary: true) }
      let(:claim) { build(:claim, :with_pdf_file, :with_text_file, number_of_claimants: 0, claim_claimants: claim_claimants) }

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
    end

    context 'with an error injected when second claim out of 3 is processed' do
      subject(:exporter) { described_class.new claim_export_service: claim_export_service_class }

      let(:claim_export_service_class) { class_double ClaimExportService }
      let(:claim_export_service1) { ClaimExportService.new(claims[0]) }
      let(:claim_export_service2) { ClaimExportService.new(claims[1]) }
      let(:claim_export_service3) { ClaimExportService.new(claims[2]) }
      let(:claims) { create_list(:claim, 3, :ready_for_export, :with_pdf_file, :with_text_file, number_of_claimants: 1) }

      # This is just one way of forcing an error.  Each iteration uses the claim export service's :export_pdf method
      # so we force that to raise an error
      before do
        allow(claim_export_service_class).to receive(:new).with(claims[0]).and_return claim_export_service1
        allow(claim_export_service_class).to receive(:new).with(claims[1]).and_return claim_export_service2
        allow(claim_export_service_class).to receive(:new).with(claims[2]).and_return claim_export_service3
        allow(claim_export_service2).to receive(:export_txt).and_raise(StandardError)
      end

      it 'exports a pdf for the first and last claim' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          aggregate_failures 'Validating pdfs do exist for 2 claims and not for the other' do
            expect(Dir.glob(File.join(dir, "#{claims[0].reference}_ET1_First_*.pdf"))).to be_present
            expect(Dir.glob(File.join(dir, "#{claims[1].reference}_ET1_First_*.pdf"))).to be_empty
            expect(Dir.glob(File.join(dir, "#{claims[2].reference}_ET1_First_*.pdf"))).to be_present
          end
        end
      end
    end

    context 'with an error injected when second and fourth claim out of 5 is processed' do
      subject(:exporter) { described_class.new claim_export_service: claim_export_service_class }

      let(:claim_export_service_class) { class_double ClaimExportService }
      let(:claim_export_service1) { ClaimExportService.new(claims[0]) }
      let(:claim_export_service2) { ClaimExportService.new(claims[1]) }
      let(:claim_export_service3) { ClaimExportService.new(claims[2]) }
      let(:claim_export_service4) { ClaimExportService.new(claims[3]) }
      let(:claim_export_service5) { ClaimExportService.new(claims[4]) }
      let(:claims) { create_list(:claim, 5, :ready_for_export, :with_pdf_file, :with_text_file, number_of_claimants: 1) }

      # This is just one way of forcing an error.  Each iteration uses the claim export service's :export_pdf and :export_txt methods
      # so we force one of each of those to raise an error.  This will prove that no stray files are left behind if the
      # code exits from different points.
      before do
        allow(claim_export_service_class).to receive(:new).with(claims[0]).and_return claim_export_service1
        allow(claim_export_service_class).to receive(:new).with(claims[1]).and_return claim_export_service2
        allow(claim_export_service_class).to receive(:new).with(claims[2]).and_return claim_export_service3
        allow(claim_export_service_class).to receive(:new).with(claims[3]).and_return claim_export_service4
        allow(claim_export_service_class).to receive(:new).with(claims[4]).and_return claim_export_service5
        allow(claim_export_service2).to receive(:export_txt).and_raise(StandardError)
        allow(claim_export_service4).to receive(:export_pdf).and_raise(StandardError)
      end

      it 'exports a pdf for the first, third and last claim' do
        Dir.mktmpdir do |dir|
          exporter.export(to: dir)
          aggregate_failures 'Verifying presence of all claims pdf files' do
            expect(Dir.glob(File.join(dir, "#{claims[0].reference}_ET1_First_*.pdf"))).to be_present
            expect(Dir.glob(File.join(dir, "#{claims[1].reference}_ET1_First_*.pdf"))).to be_empty
            expect(Dir.glob(File.join(dir, "#{claims[2].reference}_ET1_First_*.pdf"))).to be_present
            expect(Dir.glob(File.join(dir, "#{claims[3].reference}_ET1_First_*.pdf"))).to be_empty
            expect(Dir.glob(File.join(dir, "#{claims[4].reference}_ET1_First_*.pdf"))).to be_present
          end
        end
      end
    end
  end
end
