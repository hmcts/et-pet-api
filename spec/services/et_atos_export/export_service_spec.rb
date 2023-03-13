require 'rails_helper'

module EtAtosExport
  RSpec.describe ExportService do
    let(:system) { ExternalSystem.where(reference: 'atos').first }

    describe '#export' do
      subject(:service) { described_class.new(system: system) }

      # Setup 2 claims that are ready for export
      let!(:claims) do
        create_list(:claim, 2, :with_pdf_file, :with_text_file, ready_for_export_to: [system.id])
      end

      let!(:responses) do
        create_list(:response, 2, :with_pdf_file, :with_text_file, :with_rtf_file, ready_for_export_to: [system.id])
      end

      it 'produces an EtAtosFileTransfer::ExportedFile' do
        expect { service.export }.to change(EtAtosFileTransfer::ExportedFile, :count).by(1)
      end

      it 'produces and EtAtosFileTransfer::ExportedFile with the correct filename' do
        # Act
        service.export

        # Assert
        # ET_Fees_DDMMYYHHMMSS.zip
        expect(EtAtosFileTransfer::ExportedFile.last).to have_attributes filename: matching(/\AET_Fees_(?:\d{12})\.zip\z/)
      end

      it 'produces and EtAtosFileTransfer::ExportedFile with the correct external_system_id' do
        # Act
        service.export

        # Assert
        # ET_Fees_DDMMYYHHMMSS.zip
        expect(EtAtosFileTransfer::ExportedFile.last).to have_attributes external_system_id: system.id
      end

      it 'produces a zip file that contains the pdf file for each claim' do
        # Act
        service.export

        # Assert
        expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }
        expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
      end

      it 'produces a zip file that contains the correct pdf file contents for each claim' do
        # Act
        service.export
        expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }

        # Assert - unzip files to temp dir - and validate just the first and last - no reason any others would be different
        ::Dir.mktmpdir do |dir|
          EtApi::Test::StoredZipFile.extract zip: EtAtosFileTransfer::ExportedFile.last, to: dir
          files_found = ::Dir.glob(File.join(dir, '*ET1_*.pdf'))
          aggregate_failures 'verifying first and last files' do
            expect(files_found.first).to be_a_file_copy_of(File.join(dir, expected_filenames.first))
            expect(files_found.last).to be_a_file_copy_of(File.join(dir, expected_filenames.last))
          end
        end
      end

      it 'produces a zip file that contains a txt file for each claim' do
        # Act
        service.export

        # Assert
        expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.txt" }
        expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
      end

      it 'produces a zip file that does not contain the additional claimants text file' do
        # Act
        service.export

        # Assert
        expected_filenames = claims.map { |c| "#{c.reference}_ET1a_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.txt" }
        expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).not_to include(*expected_filenames)
      end

      it 'produces a zip file that contains a txt file for each response' do
        # Act
        service.export

        # Assert
        expected_filenames = responses.map do |r|
          company_name_underscored = r.respondent.name.parameterize(separator: '_', preserve_case: true)
          "#{r.reference}_ET3_#{company_name_underscored}.txt"
        end
        expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
      end

      it 'produces a zip file that contains an additional information file for each response' do
        # Act
        service.export

        # Assert
        expected_filenames = responses.map do |r|
          company_name_underscored = r.respondent.name.parameterize(separator: '_', preserve_case: true)
          "#{r.reference}_ET3_Attachment_#{company_name_underscored}.pdf"
        end
        expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
      end

      it 'produces only one zip file when called twice' do
        run_twice = lambda do
          described_class.new(system: system).export
          service.export
        end

        expect(&run_twice).to change(EtAtosFileTransfer::ExportedFile, :count).by(1)
      end

      context 'with multiple claimants from a CSV file' do
        let!(:claims) do
          create_list(:claim, 2, :with_pdf_file, :with_text_file, :with_claimants_text_file, :with_claimants_csv_file, number_of_claimants: 11, ready_for_export_to: [system.id])
        end

        it 'produces a zip file that contains an ET1a txt file for each claim' do
          # Act
          service.export

          # Assert
          expected_filenames = claims.map { |c| "#{c.reference}_ET1a_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.txt" }
          expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
        end

        it 'produces a zip file that contains an ET1a csv file for each claim' do
          # Act
          service.export

          # Assert
          expected_filenames = claims.map { |c| "#{c.reference}_ET1a_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.csv" }
          expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
        end
      end

      context 'with a single claimant, respondent and representative with an uploaded rtf file' do
        let!(:claims) do
          create_list(:claim, 2, :with_pdf_file, :with_text_file, :with_processed_rtf_file, ready_for_export_to: [system.id])
        end

        it 'produces a zip file that contains an rtf file for each claim' do
          # Act
          service.export

          # Assert
          expected_filenames = claims.map { |c| "#{c.reference}_ET1_Attachment_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }
          expect(EtApi::Test::StoredZipFile.file_names(zip: EtAtosFileTransfer::ExportedFile.last)).to include(*expected_filenames)
        end
      end

      context 'with nothing to process', db_clean: true do
        let(:system) { create(:external_system, :atos) } # rubocop:disable RSpec/LetSetup - as I want to overwrite the original
        # This time, the claims and responses are not marked as to be exported
        let!(:claims) do # rubocop:disable RSpec/LetSetup - as I want to overwrite the original
          create_list(:claim, 2, :with_pdf_file)
        end
        let!(:responses) do # rubocop:disable RSpec/LetSetup - as I want to overwrite the original
          create_list(:response, 2, :with_pdf_file, :with_text_file)
        end

        it 'does not produce a zip file if there is nothing to process' do
          expect { service.export }.to change(EtAtosFileTransfer::ExportedFile, :count).by(0)
        end
      end
    end

  end
end
