FactoryBot.define do
  factory :claim do
    transient do
      number_of_claimants { 1 }
      ready_for_export_to { [] }
    end

    sequence :reference do |n|
      "#{office_code}#{20000000 + n}00"
    end

    sequence :submission_reference do |n|
      "J704-ZK5E#{n}"
    end

    submission_channel { 'Web' }
    case_type { 'Single' }
    jurisdiction { 2 }
    office_code { 22 }
    date_of_receipt { Time.zone.now }
    pdf_template_reference { "et1-v1-en" }

    after(:build) do |claim, evaluator|
      claim.primary_claimant = build(:claimant) if claim.primary_claimant.blank? && evaluator.number_of_claimants > 0
      claim.secondary_claimants.concat build_list(:claimant, [evaluator.number_of_claimants - 1,0].max)
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

    trait :without_representative do
      primary_representative { nil }
    end

    trait :with_example_employment_details do
      employment_details do
        {
          "start_date": "2009-11-18",
          "end_date": nil,
          "notice_period_end_date": nil,
          "job_title": "agriculturist",
          "average_hours_worked_per_week": 38.0,
          "gross_pay": 3000,
          "gross_pay_period_type": "monthly",
          "net_pay": 2000,
          "net_pay_period_type": "monthly",
          "worked_notice_period_or_paid_in_lieu": nil,
          "notice_pay_period_type": nil,
          "notice_pay_period_count": nil,
          "enrolled_in_pension_scheme": true,
          "benefit_details": "Company car, private health care",
          "found_new_job": nil,
          "new_job_start_date": nil,
          "new_job_gross_pay": nil
        }.stringify_keys
      end
    end

    after(:create) do |claim, evaluator|
      evaluator.ready_for_export_to.each do |external_system_id|
        Export.create resource: claim, external_system_id: external_system_id
      end
    end

    trait :example_data do
      with_example_employment_details
      reference { "222000000300" }
      date_of_receipt { Time.zone.parse('29/3/2018') }
      number_of_claimants { 0 }
      primary_claimant { build(:claimant, :example_data) }
      secondary_claimants { [] }
      primary_respondent { build(:respondent, :example_data) }
      primary_representative { build(:representative, :example_data) }
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
