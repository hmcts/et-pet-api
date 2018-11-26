require 'rails_helper'

module EtAtosExport
  RSpec.describe ClaimFileBuilder::BuildClaimTextFile do
    subject(:builder) { described_class }

    describe '#call' do
      context 'with a single claimant, respondent and representative' do
        let(:claim) { create(:claim, :example_data) }

        it 'stores an ET1 txt file with the correct filename' do
          # Act
          builder.call(claim)

          # Assert
          expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_First_Last.txt',
                                                                              file: be_a_stored_file

        end

        it 'stores an ET1 txt file with the correct contents' do
          # Act
          builder.call(claim)
          claim.save

          # Assert
          uploaded_file = claim.uploaded_files.where(filename: 'et1_First_Last.txt').first
          expect(uploaded_file.file.download).to be_valid_et1_claim_text
        end
      end

      context 'with a single claimant, respondent and representative with unicode data present' do
        let(:claim) { create(:claim, :example_data, primary_claimant: build(:claimant, :example_data, mobile_number: "\u202d01234 098765\u202d")) }

        it 'stores an ET1 txt file with the correct filename' do
          # Act
          builder.call(claim)

          # Assert
          expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_First_Last.txt',
                                                                              file: be_a_stored_file

        end

        it 'stores an ET1 txt file with the correct contents' do
          # Act
          builder.call(claim)
          claim.save

          # Assert
          uploaded_file = claim.uploaded_files.where(filename: 'et1_First_Last.txt').first
          expect(uploaded_file.file.download).to be_valid_et1_claim_text
        end
      end
    end
  end
end
