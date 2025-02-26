require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_claim_commands, class: '::EtApi::Test::Json::Document' do
    transient do
      number_of_secondary_claimants { 0 }
      number_of_secondary_respondents { 1 }
      number_of_representatives { 1 }
      csv_file_traits { [] }
      rtf_file_traits { [] }
      case_type { 'Single' }
      claim_traits { [:full] }
      primary_respondent_traits { [:full] }
      primary_claimant_traits { [:mr_first_last_in_uk] }
      secondary_claimant_traits { [:mr_first_last] }
      secondary_respondent_traits { [:full] }
      primary_representative_traits { [:full] }
      pdf_template { 'et1-v5-en' }
      email_template { 'et1-v1-en' }
    end

    uuid { SecureRandom.uuid }
    command { 'SerialSequence' }
    data { [] }

    trait :with_csv do
      case_type { 'Multiple' }
      csv_file_traits { [:simple_user_with_csv_group_claims] }
    end

    trait :with_csv_direct_upload do
      case_type { 'Multiple' }
      csv_file_traits { [:simple_user_with_csv_group_claims] }
    end

    trait :with_csv_uppercased do
      case_type { 'Multiple' }
      csv_file_traits { [:simple_user_with_csv_group_claims_uppercased] }
    end

    trait :with_csv_direct_upload_uppercased do
      case_type { 'Multiple' }
      csv_file_traits { [:simple_user_with_csv_group_claims_uppercased] }
    end

    trait :with_rtf do
      rtf_file_traits { [:simple_user_with_rtf] }
    end

    trait :with_rtf_direct_upload do
      rtf_file_traits { [:simple_user_with_rtf] }
    end

    trait :with_rtf_uppercased do
      rtf_file_traits { [:simple_user_with_rtf_uppercased] }
    end

    trait :with_rtf_direct_upload_uppercased do
      rtf_file_traits { [:simple_user_with_rtf_uppercased] }
    end

    trait :with_welsh_pdf do
      pdf_template { 'et1-v5-cy' }
    end

    trait :with_welsh_email do
      email_template { 'et1-v1-cy' }
    end

    after(:build) do |doc, evaluator|
      evaluator.instance_eval do
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaim', data: build(:json_claim_data, *claim_traits, pdf_template_reference: pdf_template, email_template_reference: email_template, reference: nil, case_type: case_type))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRespondent', data: build(:json_respondent_data, *primary_respondent_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryClaimant', data: build(:json_claimant_data, *primary_claimant_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryClaimants', data: build_list(:json_claimant_data, number_of_secondary_claimants, *secondary_claimant_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryRespondents', data: build_list(:json_respondent_data, number_of_secondary_respondents, *secondary_respondent_traits))

        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRepresentative', data: build(:json_representative_data, *primary_representative_traits)) if number_of_representatives > 0
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimantsFile', data: build(:json_file_data, *csv_file_traits)) if csv_file_traits.present?
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimDetailsFile', data: build(:json_file_data, *rtf_file_traits)) if rtf_file_traits.present?
      end
    end

  end
  factory :json_import_claim_commands, class: '::EtApi::Test::Json::Document', parent: :json_build_claim_commands do
    command { 'ImportClaim' }
  end
  factory :json_repair_claim_command, class: '::EtApi::Test::Json::Document' do
    transient do
      claim_id { nil }
    end
    uuid { SecureRandom.uuid }
    command { 'RepairClaim' }
    data { { claim_id: claim_id } }
  end
  factory :json_claim_data, class: '::EtApi::Test::Json::Node' do
    trait :minimal do
      example_employment_details
      reference { nil }
      sequence :submission_reference do |n|
        "J704-ZK5E#{n}"
      end
      submission_channel { 'Web' }
      case_type { 'Single' }
      jurisdiction { '2' }
      office_code { '22' }
      date_of_receipt { Time.zone.now.strftime('%Y-%m-%dT%H:%M:%S%z') }
      time_zone { 'London' }

      other_known_claimant_names { "" }
      other_known_claimants { false }
      discrimination_claims do
        [
          "sex_including_equal_pay",
          "disability",
          "race",
          "age",
          "pregnancy_or_maternity",
          "religion_or_belief",
          "sexual_orientation",
          "marriage_or_civil_partnership",
          "gender_reassignment"
        ]
      end
      pay_claims do
        [
          "redundancy",
          "notice",
          "holiday",
          "arrears",
          "other"
        ]
      end
      desired_outcomes { [] }
      other_claim_details { "Other claim details" }
      claim_details { "Claim details" }
      other_outcome { "" }
      send_claim_to_whistleblowing_entity { false }
      miscellaneous_information { 'Miscellaneous Information' }
      is_unfair_dismissal { false }
      pdf_template_reference { "et1-v5-en" }
      email_template_reference { "et1-v1-en" }
      confirmation_email_recipients { ['confirmation_recipient@digital.justice.gov.uk'] }
      was_employed { false }
      whistleblowing_regulator_name { nil }
      is_whistleblowing { false }
      case_heard_by_preference { 'judge' }
      case_heard_by_preference_reason { 'I get intimidated by a group of people' }
    end
    trait :full do
      minimal
    end
    trait :example_employment_details do
      employment_details do
        {
          start_date: "2009-11-18",
          end_date: nil,
          notice_period_end_date: nil,
          job_title: "agriculturist",
          current_situation: "still_employed",
          average_hours_worked_per_week: 38.0,
          gross_pay: 3000,
          gross_pay_period_type: "monthly",
          net_pay: 2000,
          net_pay_period_type: "monthly",
          worked_notice_period_or_paid_in_lieu: nil,
          notice_pay_period_type: nil,
          notice_pay_period_count: nil,
          enrolled_in_pension_scheme: true,
          benefit_details: "Company car, private health care",
          found_new_job: nil,
          new_job_start_date: nil,
          new_job_gross_pay: nil
        }.stringify_keys
      end
    end

    trait :worked_notice_period do
      employment_details do
        {
          start_date: "2009-11-18",
          end_date: nil,
          notice_period_end_date: nil,
          job_title: "agriculturist",
          current_situation: "notice_period",
          average_hours_worked_per_week: 38.0,
          gross_pay: 3000,
          gross_pay_period_type: "monthly",
          net_pay: 2000,
          net_pay_period_type: "monthly",
          worked_notice_period_or_paid_in_lieu: true,
          notice_pay_period_type: 'months',
          notice_pay_period_count: 3.0,
          enrolled_in_pension_scheme: true,
          benefit_details: "Company car, private health care",
          found_new_job: nil,
          new_job_start_date: nil,
          new_job_gross_pay: nil
        }.stringify_keys
      end
    end
  end
end
FactoryBot.define do
  factory :json_assign_claim_command, class: '::EtApi::Test::Json::Document' do
    transient do
      claim_id { nil }
      office_id { nil }
      user_id { nil }
    end
    uuid { SecureRandom.uuid }
    command { 'AssignClaim' }
    data do
      {
        office_id: office_id,
        claim_id: claim_id,
        user_id: user_id
      }
    end
  end
end
