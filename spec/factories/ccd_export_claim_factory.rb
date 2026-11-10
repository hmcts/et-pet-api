FactoryBot.define do
  factory :ccd_export_claim, class: '::EtApi::Test::Json::Node' do
    transient do
      number_of_claimants { 1 }
      number_of_respondents { 1 }
      primary_respondent_traits { [:full] }
      primary_respondent_attrs { {} }
      primary_claimant_attrs { {} }
      primary_claimant_traits { [:default] }
      secondary_claimant_traits { [:from_csv] }
      secondary_respondent_traits { [:basic] }
      secondary_respondent_attrs { {} }
      primary_representative_traits { [:full] }
      primary_representative_attrs { {} }
      employment_details_traits { [:employed] }
      employment_details_attrs { {} }
      number_of_acas_files { 0 }
    end

    trait :default do
      with_pdf_file
      with_acas_pdf_file
      sequence :reference do |n|
        "#{office_code}#{20000000 + n}00"
      end

      sequence :submission_reference do |n|
        "J704-ZK5E#{n}"
      end
      claimant_count { number_of_claimants }
      submission_channel { "Web" }
      case_type { "Single" }
      jurisdiction { 2 }
      office_code { 22 }
      date_of_receipt { "2019-03-30T07:28:58.000Z" }
      other_known_claimant_names { "James Blunt, Punky Brewsters, Shirley Temple" }
      discrimination_claims { ["sex_including_equal_pay"] }
      pay_claims { ["redundancy"] }
      desired_outcomes { ["compensation_only"] }
      other_claim_details { "This is the other claim details field" }
      claim_details { "This is the claim details field" }
      other_outcome { "I would like 50,000GBP for the stress this has caused me" }
      send_claim_to_whistleblowing_entity { false }
      miscellaneous_information { nil }
      is_unfair_dismissal { false }
      case_heard_by_preference { 'judge' }
      case_heard_by_preference_reason { 'I feel intimidated by a group of people' }
      last_event_date { '2022-12-31' }
    end

    trait :update_only do
      number_of_respondents { 0 }
      primary_representative_traits { nil }
      employment_details_traits { nil }
      number_of_claimants { nil }
    end

    secondary_claimants { [] }
    secondary_respondents { [] }
    uploaded_files { [] }

    after(:build) do |claim, evaluator|
      claim.primary_claimant = build(:ccd_export_claimant, *evaluator.primary_claimant_traits, **evaluator.primary_claimant_attrs) if claim.primary_claimant.blank? && evaluator.number_of_claimants && evaluator.number_of_claimants > 0
      claim.secondary_claimants.concat build_list(:ccd_export_claimant, evaluator.number_of_claimants - 1, *evaluator.secondary_claimant_traits) unless evaluator.number_of_claimants.nil? || evaluator.number_of_claimants < 1
      claim.primary_respondent = build(:ccd_export_respondent, *evaluator.primary_respondent_traits, **evaluator.primary_respondent_attrs) if claim.primary_respondent.blank? && evaluator.number_of_respondents > 0
      claim.secondary_respondents.concat build_list(:ccd_export_respondent, evaluator.number_of_respondents - 1, *evaluator.secondary_respondent_traits, **evaluator.secondary_respondent_attrs) unless evaluator.number_of_respondents < 1
      claim.claimant_count         = evaluator.number_of_claimants unless evaluator.number_of_claimants.nil?
      claim.primary_representative = build(:ccd_export_representative, *evaluator.primary_representative_traits, **evaluator.primary_representative_attrs) unless evaluator.primary_representative_traits.nil?
      claim.employment_details     = build(:ccd_export_employment_details, *evaluator.employment_details_traits, **evaluator.employment_details_attrs) unless evaluator.employment_details_traits.nil?
      claim.uploaded_files.concat build_list(:ccd_export_uploaded_file, evaluator.number_of_acas_files, :example_acas_pdf)
    end

    trait :with_pdf_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:ccd_export_uploaded_file, :example_pdf)
      end
    end

    trait :with_acas_pdf_file do
      number_of_acas_files { 1 }
    end

    trait :with_claim_details_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files.unshift build(:ccd_export_uploaded_file, :example_claim_details)
      end
    end

    trait :with_claimants_csv_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:ccd_export_uploaded_file, :example_claim_claimants_csv)
      end
    end

    trait :with_unwanted_claim_file do
      after(:build) do |claim, _evaluator|
        claim.uploaded_files << build(:ccd_export_uploaded_file, :unwanted_claim_file)
      end
    end

    trait :no_representative do
      primary_representative_traits { [] }
    end

    trait :default_multiple_claimants do
      default
      multiple_claimants
    end

    trait :multiple_claimants do
      with_claimants_csv_file
      secondary_claimants do
        [
          build(:ccd_export_claimant, :csv_tamara_swift),
          build(:ccd_export_claimant, :csv_diana_flatley),
          build(:ccd_export_claimant, :csv_mariana_mccullough),
          build(:ccd_export_claimant, :csv_eden_upton),
          build(:ccd_export_claimant, :csv_annie_schulist),
          build(:ccd_export_claimant, :csv_thad_johns),
          build(:ccd_export_claimant, :csv_coleman_kreiger),
          build(:ccd_export_claimant, :csv_jenson_deckow),
          build(:ccd_export_claimant, :csv_darien_bahringer),
          build(:ccd_export_claimant, :csv_eulalia_hammes)
        ]
      end
    end
  end
end
