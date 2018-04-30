require 'rails_helper'

RSpec.describe ClaimsExportService do
  describe '#export' do
    subject(:service) { described_class.new }

    # Setup 2 claims that are ready for export
    let!(:claims) do
      create_list(:claim, 2, :with_pdf_file, :with_xml_file, :with_text_file, :ready_for_export)
    end

    it 'produces an ExportedFile' do
      expect { service.export }.to change(ExportedFile, :count).by(1)
    end

    it 'produces and ExportedFile with the correct filename' do
      # Act
      service.export

      # Assert
      # ET_Fees_DDMMYYHHMMSS.zip
      expect(ExportedFile.last).to have_attributes filename: matching(/\AET_Fees_(?:\d{12})\.zip\z/)
    end

    it 'produces a zip file that contains the pdf file for each claim' do
      # Act
      service.export

      # Assert
      expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }
      expect(ETApi::Test::StoredZipFile.file_names(zip: ExportedFile.last)).to include(*expected_filenames)
    end

    it 'produces a zip file that contains the correct pdf file contents for each claim' do
      # Act
      service.export
      expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }

      # Assert - unzip files to temp dir - and validate just the first and last - no reason any others would be different
      ::Dir.mktmpdir do |dir|
        ETApi::Test::StoredZipFile.extract zip: ExportedFile.last, to: dir
        files_found = ::Dir.glob(File.join(dir, '*.pdf'))
        aggregate_failures 'verifying first and last files' do
          expect(files_found.first).to be_a_file_copy_of(File.join(dir, expected_filenames.first))
          expect(files_found.last).to be_a_file_copy_of(File.join(dir, expected_filenames.last))
        end
      end
    end

    it 'produces a zip file that contains an xml file for each claim' do
      # Act
      service.export

      # Assert
      expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.xml" }
      expect(ETApi::Test::StoredZipFile.file_names(zip: ExportedFile.last)).to include(*expected_filenames)
    end

    it 'produces a zip file that contains a txt file for each claim' do
      # Act
      service.export

      # Assert
      expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.txt" }
      expect(ETApi::Test::StoredZipFile.file_names(zip: ExportedFile.last)).to include(*expected_filenames)
    end

    it 'produces a zip file that does not contain the additional claimants text file' do
      # Act
      service.export

      # Assert
      expected_filenames = claims.map { |c| "#{c.reference}_ET1a_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.txt" }
      expect(ETApi::Test::StoredZipFile.file_names(zip: ExportedFile.last)).not_to include(*expected_filenames)
    end

    it 'produces only one zip file when called twice' do
      run_twice = lambda do
        described_class.new.export
        service.export
      end

      expect(&run_twice).to change(ExportedFile, :count).by(1)
    end

    context 'with multiple claimants from a CSV file' do
      let!(:claims) do
        create_list(:claim, 2, :with_pdf_file, :with_xml_file, :with_text_file, :ready_for_export, :with_claimants_text_file, number_of_claimants: 11)
      end

      it 'produces a zip file that contains an ET1a txt file for each claim' do
        # Act
        service.export

        # Assert
        expected_filenames = claims.map { |c| "#{c.reference}_ET1a_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.txt" }
        expect(ETApi::Test::StoredZipFile.file_names(zip: ExportedFile.last)).to include(*expected_filenames)
      end
    end

    context 'with nothing to process' do
      # This time, the claims are not marked as to be exported
      let!(:claims) do # rubocop:disable RSpec/LetSetup - as I want to overwrite the original
        create_list(:claim, 2, :with_pdf_file)
      end

      it 'does not produce a zip file if there is nothing to process' do
        expect { service.export }.to change(ExportedFile, :count).by(0)
      end
    end
  end

end
