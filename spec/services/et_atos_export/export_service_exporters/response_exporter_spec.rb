require 'rails_helper'
module EtAtosExport
  RSpec.describe ExportServiceExporters::ResponseExporter do
    let(:system) { ExternalSystem.where(reference: 'atos').first }

    describe '#export' do
      context 'with response that has respondent with non alpha numerics in name' do
        subject(:exporter) { described_class.new(system: system)}

        let(:respondent) { build(:respondent, :mr_na_o_malley) }
        let(:response) { build(:response, :with_pdf_file, :with_text_file, :with_rtf_file, respondent: respondent) }

        # Create an export record to allow the response to be found
        before do
          Export.create resource: response, external_system_id: system.id
        end

        it 'exports a pdf file with the correct name' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            expect(File.exist?(File.join(dir, "#{response.reference}_ET3_na_OMalley.pdf"))).to be true
          end
        end

        it 'exports a txt file with the correct name' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            expect(File.exist?(File.join(dir, "#{response.reference}_ET3_na_OMalley.txt"))).to be true
          end
        end

        it 'exports an rtf file with the correct name' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            expect(File.exist?(File.join(dir, "#{response.reference}_ET3_Attachment_na_OMalley.rtf"))).to be true
          end
        end
      end

      context 'with response that has claimant with non alpha numerics in name and an underscore' do
        subject(:exporter) { described_class.new(system: system)}

        let(:respondent) { build(:respondent, :mr_na_o_malley, name: "n/a _O'Malley") }
        let(:response) { build(:response, :with_pdf_file, :with_text_file, :with_rtf_file, respondent: respondent) }

        # Create an export record to allow the claim to be found
        before do
          Export.create resource: response, external_system_id: system.id
        end

        it 'exports a pdf file with the correct name' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            expect(File.exist?(File.join(dir, "#{response.reference}_ET3_na_OMalley.pdf"))).to be true
          end
        end

        it 'exports a txt file with the correct name' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            expect(File.exist?(File.join(dir, "#{response.reference}_ET3_na_OMalley.txt"))).to be true
          end
        end

        it 'exports an rtf file with the correct name' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            expect(File.exist?(File.join(dir, "#{response.reference}_ET3_Attachment_na_OMalley.rtf"))).to be true
          end
        end
      end

      context 'with an error injected when second response out of 3 is processed' do
        subject(:exporter) { described_class.new response_export_service: response_export_service_class, system: system }

        let(:respondent) { build(:respondent) }
        let(:response_export_service_class) { class_double ::EtAtosExport::ResponseExportService }
        let(:response_export_service1) { ::EtAtosExport::ResponseExportService.new(responses[0]) }
        let(:response_export_service2) { ::EtAtosExport::ResponseExportService.new(responses[1]) }
        let(:response_export_service3) { ::EtAtosExport::ResponseExportService.new(responses[2]) }
        let(:responses) { create_list(:response, 3, :with_pdf_file, :with_text_file, :with_rtf_file, respondent: respondent, ready_for_export_to: [system.id]) }

        # This is just one way of forcing an error.  Each iteration uses the response export service's :export_txt method
        # so we force that to raise an error
        before do
          allow(response_export_service_class).to receive(:new).with(responses[0]).and_return response_export_service1
          allow(response_export_service_class).to receive(:new).with(responses[1]).and_return response_export_service2
          allow(response_export_service_class).to receive(:new).with(responses[2]).and_return response_export_service3
          allow(response_export_service2).to receive(:export_txt).and_raise(StandardError)
        end

        it 'exports a pdf for the first and last response' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            aggregate_failures 'Validating pdfs do exist for 2 responses and not for the other' do
              expect(Dir.glob(File.join(dir, "#{responses[0].reference}_ET3_*.pdf"))).to be_present
              expect(Dir.glob(File.join(dir, "#{responses[1].reference}_ET3_*.pdf"))).to be_empty
              expect(Dir.glob(File.join(dir, "#{responses[2].reference}_ET3_*.pdf"))).to be_present
            end
          end
        end
      end

      context 'with an error injected when second and fourth response out of 5 is processed' do
        subject(:exporter) { described_class.new response_export_service: response_export_service_class, system: system }

        let(:respondent) { build(:respondent) }
        let(:response_export_service_class) { class_double ::EtAtosExport::ResponseExportService }
        let(:response_export_service1) { ::EtAtosExport::ResponseExportService.new(responses[0]) }
        let(:response_export_service2) { ::EtAtosExport::ResponseExportService.new(responses[1]) }
        let(:response_export_service3) { ::EtAtosExport::ResponseExportService.new(responses[2]) }
        let(:response_export_service4) { ::EtAtosExport::ResponseExportService.new(responses[3]) }
        let(:response_export_service5) { ::EtAtosExport::ResponseExportService.new(responses[4]) }
        let(:responses) { create_list(:response, 5, :with_pdf_file, :with_text_file, :with_rtf_file, respondent: respondent, ready_for_export_to: [system.id]) }

        # This is just one way of forcing an error.  Each iteration uses the response export service's :export_pdf and :export_txt methods
        # so we force one of each of those to raise an error.  This will prove that no stray files are left behind if the
        # code exits from different points.
        before do
          allow(response_export_service_class).to receive(:new).with(responses[0]).and_return response_export_service1
          allow(response_export_service_class).to receive(:new).with(responses[1]).and_return response_export_service2
          allow(response_export_service_class).to receive(:new).with(responses[2]).and_return response_export_service3
          allow(response_export_service_class).to receive(:new).with(responses[3]).and_return response_export_service4
          allow(response_export_service_class).to receive(:new).with(responses[4]).and_return response_export_service5
          allow(response_export_service2).to receive(:export_txt).and_raise(StandardError)
          allow(response_export_service4).to receive(:export_pdf).and_raise(StandardError)
        end

        it 'exports a pdf for the first, third and last response' do
          Dir.mktmpdir do |dir|
            exporter.export(to: dir)
            aggregate_failures 'Verifying presence of all response pdf files' do
              expect(Dir.glob(File.join(dir, "#{responses[0].reference}_ET3_*.pdf"))).to be_present
              expect(Dir.glob(File.join(dir, "#{responses[1].reference}_ET3_*.pdf"))).to be_empty
              expect(Dir.glob(File.join(dir, "#{responses[2].reference}_ET3_*.pdf"))).to be_present
              expect(Dir.glob(File.join(dir, "#{responses[3].reference}_ET3_*.pdf"))).to be_empty
              expect(Dir.glob(File.join(dir, "#{responses[4].reference}_ET3_*.pdf"))).to be_present
            end
          end
        end
      end
    end
  end
end
