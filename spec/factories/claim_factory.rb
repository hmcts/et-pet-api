FactoryBot.define do
  factory :claim do
    transient do
      number_of_claimants 1
    end

    sequence :reference do |n|
      "#{office_code}#{20000000 + n}"
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
      claim.claimants.concat build_list(:claimant, evaluator.number_of_claimants)
      claim.claimant_count += evaluator.number_of_claimants
    end

    trait :with_pdf_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:uploaded_file, :example_pdf)
      end
    end

    trait :ready_for_export do
      # Ready for export MUST be in the database and files stored - so we dont do build here
      after(:create) do |claim, _evaluator|
        ClaimExport.create claim: claim
      end
    end
  end
end
