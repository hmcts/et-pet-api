require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_response_commands, class: ::EtApi::Test::Json::Document do
    trait :with_representative do
      uuid { SecureRandom.uuid }
      command 'SerialSequence'
      data do
        [
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse', data: build(:json_response_data, :full)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data, :full)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRepresentative', data: build(:json_representative_data, :private_individual))
        ]
      end
    end

    trait :with_representative_minimal do
      uuid { SecureRandom.uuid }
      command 'SerialSequence'
      data do
        [
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse', data: build(:json_response_data, :minimal)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data, :minimal)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRepresentative', data: build(:json_representative_data, :minimal))
        ]
      end
    end

    trait :without_representative do
      uuid { SecureRandom.uuid }
      command 'SerialSequence'
      data do
        [
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse', data: build(:json_response_data, :full)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data, :full))
        ]
      end
    end

    trait :with_rtf do
      uuid { SecureRandom.uuid }
      command 'SerialSequence'
      data do
        [
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse', data: build(:json_response_data, :full, :with_rtf)),
          build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data, :full))
        ]
      end
    end
  end

  factory :json_response_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do
      case_number '1454321/2017'
      agree_with_employment_dates false
      defend_claim true
    end

    trait :full do
      minimal
      claimants_name "Jane Doe"
      agree_with_early_conciliation_details false
      disagree_conciliation_reason "lorem ipsum conciliation"
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
      defend_claim_facts "lorem ipsum defence"

      make_employer_contract_claim true
      claim_information "lorem ipsum info"
      email_receipt "email@recei.pt"
    end
    additional_information_key do
      next if rtf_file_path.nil?
      config = {
        region: ENV.fetch('AWS_REGION', 'us-east-1'),
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'accessKey1'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'verySecretKey1'),
        endpoint: ENV.fetch('AWS_ENDPOINT', 'http://localhost:9000/'),
        force_path_style: ENV.fetch('AWS_S3_FORCE_PATH_STYLE', 'true') == 'true'
      }
      s3 = Aws::S3::Client.new(config)

      bucket = Aws::S3::Bucket.new(client: s3, name: Rails.configuration.s3_direct_upload_bucket)
      obj = bucket.object(SecureRandom.uuid)
      obj.put(body: File.read(rtf_file_path), content_type: 'application/rtf')
      obj.key
    end

    trait :with_rtf do
      rtf_file_path { Rails.root.join('spec', 'fixtures', 'example.rtf') }
    end
  end

  factory :json_respondent_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do
      name 'dodgy_co'
      association :address_attributes, :the_shard, factory: :json_address_data
      organisation_more_than_one_site false
    end
    trait :full do
      minimal
      contact 'John Smith'
      dx_number ""
      address_telephone_number ''
      alt_phone_number ''
      contact_preference 'email'
      email_address 'john@dodgyco.com'
      fax_number ''
      organisation_employ_gb 10
      employment_at_site_number 5
    end
  end

  factory :json_representative_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do

    end

    trait :full do
      minimal
      private_individual
    end

    trait :private_individual do
      minimal
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
end
