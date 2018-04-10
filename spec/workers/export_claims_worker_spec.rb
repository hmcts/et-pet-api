require 'rails_helper'

RSpec.describe ExportClaimsWorker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    # Setup 2 claims that are ready for export
    let!(:claims) do
      create_list(:claim, 2, :with_pdf_file, :ready_for_export)
    end

    it 'produces an ExportedFile' do
      expect { worker.perform }.to change(ExportedFile, :count).by(1)
    end

    it 'produces and ExportedFile with the correct filename' do
      # Act
      worker.perform

      # Assert
      # ET_Fees_DDMMYYHHMMSS.zip
      expect(ExportedFile.last).to have_attributes filename: matching(/\AET_Fees_(?:\d{12})\.zip\z/)
    end

    it 'produces a zip file that contains the pdf file for each claim' do
      # Act
      worker.perform

      # Assert
      expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }
      expect(ETApi::Test::StoredZipFile.file_names(zip: ExportedFile.last)).to match_array expected_filenames
    end

    it 'produces a zip file that contains the correct pdf file contents for each claim' do
      # Act
      worker.perform
      expected_filenames = claims.map { |c| "#{c.reference}_ET1_#{c.primary_claimant.first_name.tr(' ', '_')}_#{c.primary_claimant.last_name}.pdf" }

      # Assert - unzip files to temp dir - and validate just the first and last - no reason any others would be different
      ::Dir.mktmpdir do |dir|
        ETApi::Test::StoredZipFile.extract zip: ExportedFile.last, to: dir
        files_found = ::Dir.glob(File.join(dir, '*.pdf'))
        expect(files_found.first).to be_a_file_copy_of(File.join(dir, expected_filenames.first))
        expect(files_found.last).to be_a_file_copy_of(File.join(dir, expected_filenames.last))
      end

    end
  end
end
