require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_claim_commands, class: ::EtApi::Test::Json::Document do
    transient do
      number_of_secondary_claimants 0
      number_of_secondary_respondents 1
      number_of_representatives 1
      has_pdf_file true
      has_csv_file false
      has_rtf_file false
      primary_respondent_factory :full
      primary_claimant_factory :mr_first_last
      case_type 'Single'
      sequence :reference do |idx|
        "#{2220000000 + idx}00"
      end
    end

    uuid { SecureRandom.uuid }
    command 'SerialSequence'
    data do

      a = [
        build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaim', data: build(:json_claim_data, :full, reference: reference, case_type: case_type)),
        build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRespondent', data: build(:json_respondent_data, primary_respondent_factory)),
        build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryClaimant', data: build(:json_claimant_data, primary_claimant_factory)),
        build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryClaimants', data: build_list(:json_claimant_data, number_of_secondary_claimants, :mr_first_last)),
        build(:json_command, uuid: SecureRandom.uuid, command: 'BuildSecondaryRespondents', data: build_list(:json_respondent_data, number_of_secondary_respondents, :full)),
      ]
      a << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPrimaryRepresentative', data: build(:json_representative_data, :full)) if number_of_representatives > 0
      a << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildPdfFile', data: build(:json_file_data, :et1_first_last_pdf)) if has_pdf_file
      a << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimantsFile', data: build(:json_file_data, :simple_user_with_csv_group_claims)) if has_csv_file
      a << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildClaimDetailsFile', data: build(:json_file_data, :simple_user_with_rtf)) if has_rtf_file

      a

    end

    trait :with_csv do
      case_type 'Multiple'
      has_csv_file true
      number_of_secondary_claimants 10
    end

    trait :with_rtf do
      has_rtf_file true
    end



  end

  factory :json_claim_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do
      reference nil
      submission_reference 'J704-ZK5E'
      submission_channel 'Web'
      case_type 'Single'
      jurisdiction '2'
      office_code '22'
      date_of_receipt { Time.zone.now.strftime('%Y-%m-%dT%H:%M:%S%z') }

    end
    trait :full do
      minimal
    end
  end
end
