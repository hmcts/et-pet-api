require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_response_commands, class: ::EtApi::Test::Json::Document do
    transient do
      pdf_template { 'et3-v2-en' }
      email_template { 'et3-v1-en' }
      response_traits { [:full] }
      respondent_traits { [:full, :et3] }
      representative_traits { nil }
    end
    uuid { SecureRandom.uuid }
    command { 'SerialSequence' }
    data { [] }

    trait :with_welsh_pdf do
      pdf_template { 'et3-v2-cy' }
    end

    trait :with_welsh_email do
      email_template { 'et3-v1-cy' }
    end

    trait :with_representative do
      response_traits { [:full] }
      respondent_traits { [:full] }
      representative_traits { [:private_individual] }
    end

    trait :with_representative_minimal do
      response_traits { [:minimal] }
      respondent_traits { [:minimal] }
      representative_traits { [:minimal] }
    end

    trait :without_representative do
      response_traits { [:full] }
      respondent_traits { [:full] }
      representative_traits { nil }
    end

    trait :with_rtf do
      response_traits { [:full, :with_rtf] }
      respondent_traits { [:full] }
      representative_traits { nil }
    end

    trait :invalid_case_number do
      response_traits { [:full, :invalid_case_number] }
      respondent_traits { [:full] }
      representative_traits { nil }
    end

    trait :for_default_office do
      response_traits { [:full, :for_default_office] }
      respondent_traits { [:full] }
      representative_traits { nil }
    end

    after(:build) do |doc, evaluator|
      evaluator.instance_eval do
        if response_traits
          doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildResponse',
                                           data: build(:json_response_data, *response_traits, pdf_template_reference: pdf_template, email_template_reference: email_template))
        end
        if respondent_traits
          doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRespondent', data: build(:json_respondent_data, *respondent_traits))
        end
        if representative_traits
          doc.data << build(:json_command, uuid: SecureRandom.uuid, command: 'BuildRepresentative', data: build(:json_representative_data, *representative_traits))
        end
      end
    end
  end

  factory :json_response_data, class: ::EtApi::Test::Json::Node do
    transient do
      rtf_file_path { nil }
    end
    trait :minimal do
      case_number { '1454321/2017' }
      agree_with_employment_dates { false }
      defend_claim { true }
    end

    trait :full do
      minimal
      claimants_name { "Jane Doe" }
      agree_with_early_conciliation_details { false }
      disagree_conciliation_reason { "lorem ipsum conciliation" }
      employment_start { "2017-01-01" }
      employment_end { "2017-12-31" }
      disagree_employment { "lorem ipsum employment" }
      continued_employment { true }
      agree_with_claimants_description_of_job_or_title { false }
      disagree_claimants_job_or_title { "lorem ipsum job title" }
      agree_with_claimants_hours { false }
      queried_hours { 101.01 }
      agree_with_earnings_details { false }
      queried_pay_before_tax { 1000.0 }
      queried_pay_before_tax_period { "Monthly" }
      queried_take_home_pay { 900.0 }
      queried_take_home_pay_period { "Monthly" }
      agree_with_claimant_notice { false }
      disagree_claimant_notice_reason { "lorem ipsum notice reason" }
      agree_with_claimant_pension_benefits { false }
      disagree_claimant_pension_benefits_reason { "lorem ipsum claimant pension" }
      defend_claim_facts { "lorem ipsum defence" }

      make_employer_contract_claim { true }
      claim_information { "lorem ipsum info" }
      email_receipt { "email@recei.pt" }
      pdf_template_reference { "et3-v2-en" }
      email_template_reference { "et3-v1-en" }
    end

    trait :invalid_case_number do
      case_number { '6554321/2017' }
    end

    trait :invalid_queried_hours do
      queried_hours { 168.01 }
    end

    trait :for_default_office do
      full
      case_number { '9954321/2017' }
    end

    additional_information_key do
      next if rtf_file_path.nil?

      key = ActiveStorage::Blob.generate_unique_secure_token
      config = Rails.configuration.active_storage
      service = ActiveStorage::Service.configure :"#{config.service}_direct_upload", config.service_configurations
      signed_uri = service.url_for_direct_upload key, expires_in: 1.hour, content_type: nil, content_length: nil, checksum: nil
      headers = {
        "User-Agent": "Azure-Storage/0.15.0-preview (Ruby 2.5.1-p57; MacOS darwin17.6.0)",
        "x-ms-date": "Wed, 06 Mar 2019 14:00:46 GMT",
        "x-ms-version": "2016-05-31",
        "x-ms-blob-type": "BlockBlob",
        "Accept": 'application/json'
      }
      file = File.open(rtf_file_path, 'r')
      begin
        response = HTTParty.put(signed_uri, headers: headers, body_stream: file)
        raise "RTF File not uploaded to blob server" unless response.code == 201
      ensure
        file.close
      end
      key
    end

    trait :with_rtf do
      rtf_file_path { Rails.root.join('spec', 'fixtures', 'example.rtf') }
    end
  end
end
