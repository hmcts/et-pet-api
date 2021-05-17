require 'rails_helper'
RSpec.describe EtAtosExport::ClaimFileBuilder::BuildClaimantsTextFile do
  subject(:builder) { described_class }

  describe '#call' do
    context 'with 11 claimants, 1 respondent and representative' do
      let(:claim) { create(:claim, :example_data_multiple_claimants) }

      it 'stores an ET1a txt file with the correct filename' do
        # Act
        builder.call(claim)

        # Assert
        expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1a_First_Last.txt',
                                                                            file: be_a_stored_file
      end

      it 'stores an ET1a txt file with the correct contents' do
        # Act
        builder.call(claim)
        claim.save

        # Assert
        uploaded_file = claim.uploaded_files.where(filename: 'et1a_First_Last.txt').first
        expect(uploaded_file.file.download).to be_valid_et1a_claim_text(claim: claim)
      end
    end
  end
end
