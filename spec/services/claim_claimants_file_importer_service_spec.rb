require 'rails_helper'
RSpec.describe ClaimClaimantsFileImporterService do
  subject(:service) { described_class.new(claim) }

  # The claim is setup the same as a claim that has come in via JSON - which means the file will have been renamed to be what ETHOS export expects
  let(:built_claim) do
    claimant = build(:claimant)
    build :claim,
      uploaded_files: [build(:uploaded_file, :example_claim_claimants_csv, filename: "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv")],
      primary_claimant: claimant
  end
  let(:claim) { built_claim.tap(&:save!) }

  describe '#call' do
    context 'with unsaved claim' do
      subject(:service) { described_class.new(built_claim) }

      it 'raises an error as these cannot be built in memory' do
        expect { service.call }.to raise_exception RuntimeError, 'The claim must be saved with no changes before this importer can be used'
      end
    end

    context 'with saved claim' do
      it 'imports the rows from the csv file into the claims claimants' do
        # Act
        service.call

        # Assert
        map = lambda do |c|
          c[:address] = an_object_having_attributes(c[:address])
          an_object_having_attributes(c)
        end
        expect(claim.secondary_claimants).to match_array normalize_claimants_from_file.map(&map)
      end
    end
  end

end
