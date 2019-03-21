require 'rails_helper'
RSpec.describe ClaimClaimantsFileImporterService do
  subject(:service) { described_class.new(claim) }

  # The claim is setup the same as a claim that has come in via JSON - which means the file will have been renamed to be what ETHOS export expects
  let(:built_claim) do
    claimant = build(:claimant)
    build :claim,
      uploaded_files: [build(:uploaded_file, example_file_trait, filename: "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv")],
      primary_claimant: claimant
  end
  let(:claim) { built_claim.tap(&:save!) }
  let(:example_file_trait) { :example_claim_claimants_csv }

  describe '#call' do
    context 'with unsaved claim' do
      subject(:service) { described_class.new(built_claim) }

      it 'raises an error as these cannot be built in memory' do
        expect { service.call }.to raise_exception RuntimeError, 'The claim must be saved with no changes before this importer can be used'
      end
    end

    context "with simple csv" do
      let(:example_file_trait) { :example_claim_claimants_csv }

      context 'with saved claim' do
        it 'imports the rows from the csv file into the claims claimants' do
          # Act
          service.call

          # Assert
          map = lambda do |c|
            c[:address] = an_object_having_attributes(c[:address])
            an_object_having_attributes(c)
          end
          expect(claim.secondary_claimants.includes(:address)).to match_array normalize_claimants_from_file.map(&map)
        end
      end
    end

    context "with csv full of horrible encoding issues" do
      let(:example_file_trait) { :example_claim_claimants_csv_bad_encoding }

      context 'with saved claim' do
        it 'imports the rows from the csv file into the claims claimants' do
          # Act
          service.call

          # Assert
          filename = build(:uploaded_file, example_file_trait).file.filename.to_s
          full_path = File.absolute_path("../fixtures/#{filename}", __dir__)
          map = lambda do |c|
            c[:address] = an_object_having_attributes(c[:address])
            an_object_having_attributes(c)
          end
          expect(claim.secondary_claimants.includes(:address)).to match_array normalize_claimants_from_file(file: full_path).map(&map)
        end
      end
    end
  end

end
