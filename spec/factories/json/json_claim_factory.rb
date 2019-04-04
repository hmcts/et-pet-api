require 'faker'
require 'securerandom'

# @TODO RST-1729 - The direct_upload variants will become the norm and we will remove the old url variants and re use the name of the old variant so we no longer have 'direct_upload' in the name
FactoryBot.define do
  factory :json_build_claim_commands, class: ::EtApi::Test::Json::Document do
    transient do
      number_of_secondary_claimants { 0 }
      number_of_secondary_respondents { 1 }
      number_of_representatives { 1 }
      has_pdf_file { false }
      csv_file_traits { [] }
      rtf_file_traits { [] }
      case_type { 'Single' }
      sequence :reference do |idx|
        "#{2220000000 + idx}00"
      end
      claim_traits { [:full] }
      primary_respondent_traits { [:full] }
      primary_claimant_traits { [:mr_first_last] }
      secondary_claimant_traits { [:mr_first_last] }
      secondary_respondent_traits { [:full] }
      primary_representative_traits { [:full] }
      pdf_template { 'et1-v1-en' }
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
      csv_file_traits { [:simple_user_with_csv_group_claims, :direct_upload] }
    end

    trait :with_csv_uppercased do
      case_type { 'Multiple' }
      csv_file_traits { [:simple_user_with_csv_group_claims_uppercased] }
    end

    trait :with_csv_direct_upload_uppercased do
      case_type { 'Multiple' }
      csv_file_traits { [:simple_user_with_csv_group_claims_uppercased, :direct_upload] }
    end

    trait :with_rtf do
      rtf_file_traits { [:simple_user_with_rtf] }
    end

    trait :with_rtf_direct_upload do
      rtf_file_traits { [:simple_user_with_rtf, :direct_upload] }
    end

    trait :with_rtf_uppercased do
      rtf_file_traits { [:simple_user_with_rtf_uppercased] }
    end

    trait :with_rtf_direct_upload_uppercased do
      rtf_file_traits { [:simple_user_with_rtf_uppercased, :direct_upload] }
    end

    trait :with_welsh_pdf do
      pdf_template { 'et1-v1-cy' }
    end

    after(:build) do |doc, evaluator|
      evaluator.instance_eval do
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaim', data: build(:json_claim_data, *claim_traits, pdf_template_reference: pdf_template, reference: reference, case_type: case_type))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRespondent', data: build(:json_respondent_data, *primary_respondent_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryClaimant', data: build(:json_claimant_data, *primary_claimant_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryClaimants', data: build_list(:json_claimant_data, number_of_secondary_claimants, *secondary_claimant_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryRespondents', data: build_list(:json_respondent_data, number_of_secondary_respondents, *secondary_respondent_traits))

        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRepresentative', data: build(:json_representative_data, *primary_representative_traits)) if number_of_representatives > 0
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPdfFile', data: build(:json_file_data, :et1_first_last_pdf)) if has_pdf_file
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimantsFile', data: build(:json_file_data, *csv_file_traits)) if csv_file_traits.present?
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimDetailsFile', data: build(:json_file_data, *rtf_file_traits)) if rtf_file_traits.present?
      end
    end

  end
  factory :json_import_claim_commands, class: ::EtApi::Test::Json::Document, parent: :json_build_claim_commands do
    command { 'ImportClaim' }
  end
  factory :json_claim_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do
      example_employment_details
      reference { nil }
      submission_reference { 'J704-ZK5E' }
      submission_channel { 'Web' }
      case_type { 'Single' }
      jurisdiction { '2' }
      office_code { '22' }
      date_of_receipt { Time.zone.now.strftime('%Y-%m-%dT%H:%M:%S%z') }

      other_known_claimant_names { "" }
      discrimination_claims { [] }
      pay_claims { [] }
      desired_outcomes { [] }
      other_claim_details { "" }
      claim_details { "" }
      other_outcome { "" }
      send_claim_to_whistleblowing_entity { false }
      miscellaneous_information { '' }
      is_unfair_dismissal { false }
      pdf_template_reference { "et1-v1-en" }
    end
    trait :full do
      minimal
    end
    trait :example_employment_details do
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
  end
end
