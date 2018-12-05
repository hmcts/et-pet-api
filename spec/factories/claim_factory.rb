FactoryBot.define do
  factory :claim do
    transient do
      number_of_claimants 1
      ready_for_export_to []
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
      claim.primary_claimant = build(:claimant) if claim.primary_claimant.blank?
      claim.secondary_claimants.concat build_list(:claimant, evaluator.number_of_claimants - 1)
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

    after(:create) do |claim, evaluator|
      evaluator.ready_for_export_to.each do |external_system_id|
        Export.create resource: claim, external_system_id: external_system_id
      end
    end


    trait :example_data do
      reference "222000000300"
      date_of_receipt { Time.zone.parse('29/3/2018') }
      number_of_claimants 0
      primary_claimant { build(:claimant, :example_data) }
      secondary_claimants []
      respondents { [build(:respondent, :example_data)] }
      representatives { [build(:representative, :example_data)] }
      uploaded_files { [build(:uploaded_file, :example_data)] }
    end

    trait :example_data_multiple_claimants do
      example_data
      secondary_claimants do
        [
          build(:claimant, :tamara_swift),
          build(:claimant, :diana_flatley),
          build(:claimant, :mariana_mccullough),
          build(:claimant, :eden_upton),
          build(:claimant, :annie_schulist),
          build(:claimant, :thad_johns),
          build(:claimant, :coleman_kreiger),
          build(:claimant, :jenson_deckow),
          build(:claimant, :darien_bahringer),
          build(:claimant, :eulalia_hammes)
        ]
      end
      uploaded_files { [build(:uploaded_file, :example_data), build(:uploaded_file, :example_claim_claimants_csv)] }
    end

  end
end
