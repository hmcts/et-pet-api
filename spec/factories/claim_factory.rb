FactoryBot.define do
  factory :claim do
    transient do
      number_of_claimants 1
    end

    sequence :reference do |n|
      "#{office_code}#{20000000 + n}00"
    end

    sequence :submission_reference do |n|
      "J704-ZK5E#{n}"
    end

    submission_channel 'Web'
    case_type 'Single'
    jurisdiction 2
    office_code 22
    date_of_receipt { Time.zone.now }

    after(:build) do |claim, evaluator|
      claim.claim_claimants.concat build_list(:claim_claimant, evaluator.number_of_claimants)
      claim.claim_claimants.last.primary = true
      claim.claimant_count += evaluator.number_of_claimants
    end

    trait :with_pdf_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:uploaded_file, :example_pdf)
      end
    end

    trait :with_text_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:uploaded_file, :example_claim_text)
      end
    end

    trait :with_rtf_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:uploaded_file, :example_claim_rtf)
      end
    end

    trait :with_claimants_text_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:uploaded_file, :example_claim_claimants_text)
      end
    end

    trait :with_claimants_csv_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:uploaded_file, :example_claim_claimants_csv)
      end
    end

    trait :ready_for_export do
      # Ready for export MUST be in the database and files stored - so we dont do build here
      after(:create) do |claim, _evaluator|
        Export.create resource: claim
      end
    end

    trait :example_data do
      reference "222000000300"
      date_of_receipt { Time.zone.parse('29/3/2018') }
      number_of_claimants 0
      claim_claimants { [build(:claim_claimant, :example_data)] }
      respondents { [build(:respondent, :example_data)] }
      representatives { [build(:representative, :example_data)] }
      uploaded_files { [build(:uploaded_file, :example_data)] }
    end

    trait :example_data_multiple_claimants do
      example_data
      claim_claimants do
        [
          build(:claim_claimant, :example_data, primary: true),
          build(:claim_claimant, :tamara_swift),
          build(:claim_claimant, :diana_flatley),
          build(:claim_claimant, :mariana_mccullough),
          build(:claim_claimant, :eden_upton),
          build(:claim_claimant, :annie_schulist),
          build(:claim_claimant, :thad_johns),
          build(:claim_claimant, :coleman_kreiger),
          build(:claim_claimant, :jenson_deckow),
          build(:claim_claimant, :darien_bahringer),
          build(:claim_claimant, :eulalia_hammes)
        ]
      end
      uploaded_files { [build(:uploaded_file, :example_data), build(:uploaded_file, :example_claim_claimants_csv)] }
    end

  end
end
