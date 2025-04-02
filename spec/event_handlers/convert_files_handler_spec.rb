require 'rails_helper'

RSpec.describe ConvertFilesHandler do
  describe '#handle' do
    context 'with a type of claim and an rtf file given' do
      let(:claim) { create(:claim, :with_unprocessed_rtf_file) }
      let(:expected_filename) do
        claimant = claim.primary_claimant
        "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}"
      end

      it 'copies the rtf file' do
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
          expect(UploadedFile.system_file_scope.where(filename: "#{expected_filename}.rtf")).not_to be_present
        end
      end
    end
  end
end
