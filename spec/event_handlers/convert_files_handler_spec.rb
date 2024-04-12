require 'rails_helper'

RSpec.describe ConvertFilesHandler do
  describe '#handle' do
    context 'with a type of claim and an rtf file given' do
      let(:claim) { create(:claim, :with_unprocessed_rtf_file) }
      let(:expected_filename) do
        claimant = claim.primary_claimant
        "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}"
      end

      it 'converts the rtf file to a pdf file if enabled' do
        # Arrange
        allow(Rails.configuration.file_conversions).to receive(:enabled).and_return(true)
        # Act
        described_class.new.handle(claim)
        # Assert
        aggregate_failures 'files' do
          expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.pdf")).to be_present
          expect(UploadedFile.system_file_scope.where("filename LIKE '%.rtf'")).not_to be_present
        end
      end

      it 'copies the rtf file' do
        # Act
        described_class.new.handle(claim)
        # Assert
        expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.rtf")).to be_present
      end

      it 'does not convert the rtf file if the type is not allowed' do
        # Arrange
        allow(Rails.configuration.file_conversions).to receive(:allowed_types).and_return(['text/csv'])
        # Act
        described_class.new.handle(claim)
        # Assert
        expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.rtf")).to be_present
      end

      it 'does nothing if the rtf file is not present' do
        # Arrange
        claim.uploaded_files.destroy_all
        # Act
        described_class.new.handle(claim)
        # Assert
        aggregate_failures 'files' do
          expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.pdf")).not_to be_present
          expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.rtf")).not_to be_present
        end
      end

      it 'does nothing if the rtf file is already converted' do
        # Arrange
        allow(Rails.configuration.file_conversions).to receive(:enabled).and_return(true)
        described_class.new.handle(claim)
        # Act
        described_class.new.handle(claim)
        # Assert
        aggregate_failures 'files' do
          expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.pdf")).to be_present
          expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.rtf")).not_to be_present
        end
      end
    end
  end
end
