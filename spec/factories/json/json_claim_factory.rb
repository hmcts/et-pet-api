require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_claim_commands, class: ::EtApi::Test::Json::Document do
    transient do
      number_of_secondary_claimants { 0 }
      number_of_secondary_respondents { 1 }
      number_of_representatives { 1 }
      has_pdf_file { true }
      csv_file_trait { nil }
      rtf_file_trait { false }
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
    end

    uuid { SecureRandom.uuid }
    command { 'SerialSequence' }
    data { [] }

    trait :with_csv do
      case_type { 'Multiple' }
      csv_file_trait { :simple_user_with_csv_group_claims }
    end

    trait :with_csv_uppercased do
      case_type { 'Multiple' }
      csv_file_trait { :simple_user_with_csv_group_claims_uppercased }
    end

    trait :with_rtf do
      rtf_file_trait { :simple_user_with_rtf }
    end

    trait :with_rtf_uppercased do
      rtf_file_trait { :simple_user_with_rtf_uppercased }
    end

    after(:build) do |doc, evaluator|
      evaluator.instance_eval do
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaim', data: build(:json_claim_data, *claim_traits, reference: reference, case_type: case_type))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRespondent', data: build(:json_respondent_data, *primary_respondent_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryClaimant', data: build(:json_claimant_data, *primary_claimant_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryClaimants', data: build_list(:json_claimant_data, number_of_secondary_claimants, *secondary_claimant_traits))
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryRespondents', data: build_list(:json_respondent_data, number_of_secondary_respondents, *secondary_respondent_traits))

        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRepresentative', data: build(:json_representative_data, *primary_representative_traits)) if number_of_representatives > 0
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPdfFile', data: build(:json_file_data, :et1_first_last_pdf)) if has_pdf_file
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimantsFile', data: build(:json_file_data, csv_file_trait)) if csv_file_trait
        doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimDetailsFile', data: build(:json_file_data, rtf_file_trait)) if rtf_file_trait
      end
    end

  end

  factory :json_claim_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do
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
      employment_details { {} }
      is_unfair_dismissal { false }

    end
    trait :full do
      minimal
    end
  end
end
