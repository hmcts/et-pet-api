require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_respondent_data, class: '::EtApi::Test::Json::Node' do
    trait :minimal do
      name { 'dodgy_co' }
      association :address_attributes, :the_shard, factory: :json_address_data
      organisation_more_than_one_site { false }
    end

    trait :full do
      minimal
      association :work_address_attributes, :the_shard, factory: :json_address_data
      contact { 'John Smith' }
      dx_number { "" }
      address_telephone_number { '01234 567890' }
      work_address_telephone_number { '43210 567890' }
      alt_phone_number { '01234 567891' }
      contact_preference { 'email' }
      email_address { 'john@dodgyco.com' }
      organisation_employ_gb { 10 }
      employment_at_site_number { 5 }
      disability { 'true' }
      disability_information { 'Lorem ipsum disability' }
      acas_certificate_number { 'R000100/18/68' }
      acas_exemption_code { nil }
    end

    trait :no_acas_joint_claimant do
      acas_certificate_number { nil }
      acas_exemption_code { 'joint_claimant_has_acas_number' }
    end

    trait :no_acas_no_jurisdiction do
      acas_certificate_number { nil }
      acas_exemption_code { 'acas_has_no_jurisdiction' }
    end

    trait :no_acas_employer_contacted do
      acas_certificate_number { nil }
      acas_exemption_code { 'employer_contacted_acas' }
    end

    trait :no_acas_interim_relief do
      acas_certificate_number { nil }
      acas_exemption_code { 'interim_relief' }
    end

    trait :et3 do
      allow_video_attendance { true }
      allow_phone_attendance { true }
      company_number { '12378101932' }
      type_of_employer { 'Limited company' }
      title { 'Mr' }
    end

    trait :no_work_address do
      association :work_address_attributes, :empty, factory: :json_address_data
    end

    trait :no_addresses do
      association :work_address_attributes, :empty, factory: :json_address_data
      association :address_attributes, :empty, factory: :json_address_data
    end

    trait :invalid_address_keys do
      association :address_attributes, :invalid_keys, factory: :json_address_data
    end

    trait :invalid_work_address_keys do
      association :work_address_attributes, :invalid_keys, factory: :json_address_data
    end

    trait :mr_na_o_leary do
      full
      name { "n/a O'Leary" }
    end

    trait :mr_na_unicode do
      full
      name { "n/a Unicode" }
      address_telephone_number { "\u202d01234 777666\u202d" }
    end

    trait :default_office do
      full
      association :work_address_attributes, :for_default_office, factory: :json_address_data
    end

    trait :manchester_office do
      association :work_address_attributes, :for_manchester_office, factory: :json_address_data
    end

  end
end
