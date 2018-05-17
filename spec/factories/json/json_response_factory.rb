require 'faker'
require 'securerandom'
module EtApi
  module Test
    module Json
      class Node < OpenStruct
        def as_json(*)
          to_h.inject({}) do |acc, (k, v)|
            acc[k] = normalize(v)
            acc
          end
        end

        private

        def normalize(value)
          case value
          when Node then value.as_json
          when Array then value.map { |i| normalize(i) }
          else value
          end
        end
      end

      class Document < Node

      end
    end

  end
end
FactoryBot.define do
  factory :json_build_response_commands, class: ::EtApi::Test::Json::Document do
    trait :with_representative do
      uuid { SecureRandom.uuid }
      command 'SerialSequence'
      data do
        [
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse', data: build(:json_response_data)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRepresentative', data: build(:json_representative_data, :private_individual))
        ]
      end
    end

    trait :without_representative do
      uuid { SecureRandom.uuid }
      command 'SerialSequence'
      data do
        [
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse', data: build(:json_response_data)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data))
        ]
      end
    end
  end

  #   "case_number": "7654321/2017",
  #   "name": "dodgy_co",
  #   "contact": "John Smith",
  #   "building_name": "the_shard",
  #   "street_name": "downing_street",
  #   "town": "westminster",
  #   "county": "",
  #   "postcode": "wc1 1aa",
  #   "dx_number": "",
  #   "contact_number": "",
  #   "mobile_number": "",
  #   "contact_preference": "email",
  #   "email_address": "john@dodgyco.com",
  #   "fax_number": "",
  #

  factory :json_response_data, class: ::EtApi::Test::Json::Node do
    case_number '1454321/2017'
    claimants_name "Jane Doe"
    agree_with_early_conciliation_details false
    disagree_conciliation_reason "lorem ipsum conciliation"
    agree_with_employment_dates false
    employment_start "2017-01-01"
    employment_end "2017-12-31"
    disagree_employment "lorem ipsum employment"
    continued_employment true
    agree_with_claimants_description_of_job_or_title false
    disagree_claimants_job_or_title "lorem ipsum job title"
    agree_with_claimants_hours false
    queried_hours 32.0
    agree_with_earnings_details false
    queried_pay_before_tax 1000.0
    queried_pay_before_tax_period "Monthly"
    queried_take_home_pay 900.0
    queried_take_home_pay_period "Monthly"
    agree_with_claimant_notice false
    disagree_claimant_notice_reason "lorem ipsum notice reason"
    agree_with_claimant_pension_benefits false
    disagree_claimant_pension_benefits_reason "lorem ipsum claimant pension"
    defend_claim true
    defend_claim_facts "lorem ipsum defence"

    make_employer_contract_claim true
    claim_information "lorem ipsum info"
    email_receipt "email@recei.pt"
  end

  factory :json_respondent_data, class: ::EtApi::Test::Json::Node do
    name 'dodgy_co'
    contact 'John Smith'
    association :address_attributes, :the_shard, factory: :json_address_data
    dx_number ""
    address_telephone_number ''
    alt_phone_number ''
    contact_preference 'email'
    email_address 'john@dodgyco.com'
    fax_number ''
    organisation_employ_gb nil
    organisation_more_than_one_site false
    employment_at_site_number nil
  end

  factory :json_representative_data, class: ::EtApi::Test::Json::Node do
    trait :private_individual do
      name 'Jane Doe'
      organisation_name 'repco ltd'
      association :address_attributes, :rep_address, factory: :json_address_data
      address_telephone_number '0207 987 6543'
      mobile_number '07987654321'
      representative_type 'Private Individual'
      dx_number 'dx address'
      reference 'Rep Ref'
      contact_preference 'fax'
      email_address ''
      fax_number '0207 345 6789'
      disability true
      disability_information 'Lorem ipsum disability'
    end
  end

  factory :json_address_data, class: ::EtApi::Test::Json::Node do
    trait :the_shard do
      building "the_shard"
      street "downing_street"
      locality "westminster"
      county ""
      post_code "wc1 1aa"
    end

    trait :rep_address do
      building 'Rep Building'
      street 'Rep Street'
      locality 'Rep Town'
      county 'Rep County'
      post_code 'WC2 2BB'
    end
  end

  factory :json_command, class: ::EtApi::Test::Json::Node do
    command 'DummyCommand'
    data { EtApi::Test::Json::Node.new }
  end

end
