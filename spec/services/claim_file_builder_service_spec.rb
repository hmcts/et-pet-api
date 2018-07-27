require 'rails_helper'

RSpec.describe ClaimFileBuilderService do
  subject(:service) do
    described_class.new claim,
      claim_text_file_builder: claim_text_file_builder_spy,
      claimants_text_file_builder: claimants_text_file_builder_spy
  end

  # Setup for all
  # Spies for the builders which return nothing
  let(:claim_text_file_builder_spy) { class_spy(ClaimFileBuilder::BuildClaimTextFile) }
  let(:claimants_text_file_builder_spy) { class_spy(ClaimFileBuilder::BuildClaimantsTextFile) }

  describe '#call' do
    context 'with a single claimant claim' do
      let(:claim) { build(:claim, number_of_claimants: 1) }

      it 'calls the claim text file builder' do
        # Act
        service.call

        # Assert
        expect(claim_text_file_builder_spy).to have_received(:call)
      end

      it 'does not call the claimants text file builder as there is only 1 claimant' do
        # Act
        service.call

        # Assert
        expect(claimants_text_file_builder_spy).not_to have_received(:call)
      end
    end

    context 'with more than 1 claimants - 2 in this example' do
      let(:claim) { build(:claim, number_of_claimants: 2) }

      it 'calls the claim text file builder' do
        # Act
        service.call

        # Assert
        expect(claim_text_file_builder_spy).to have_received(:call)
      end

      it 'calls the claimants text file builder as there are 2 claimants' do
        # Act
        service.call

        # Assert
        expect(claimants_text_file_builder_spy).to have_received(:call)
      end
    end
  end
end
