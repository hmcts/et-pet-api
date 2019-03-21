require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_respondent_data, class: ::EtApi::Test::Json::Node do
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
      address_telephone_number { '' }
      work_address_telephone_number { '' }
      alt_phone_number { '' }
      contact_preference { 'email' }
      email_address { 'john@dodgyco.com' }
      fax_number { '' }
      organisation_employ_gb { 10 }
      employment_at_site_number { 5 }
      disability { true }
      disability_information { 'Lorem ipsum disability' }
      acas_certificate_number { 'AC123456/78/90' }
      acas_exemption_code { nil }
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

  end
end
