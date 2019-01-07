require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_representative_data, class: ::EtApi::Test::Json::Node do
    trait :minimal do

    end

    trait :full do
      minimal
      private_individual
    end

    trait :private_individual do
      minimal
      name { 'Jane Doe' }
      organisation_name { 'repco ltd' }
      association :address_attributes, :rep_address, factory: :json_address_data
      address_telephone_number { '0207 987 6543' }
      mobile_number { '07987654321' }
      representative_type { 'Private Individual' }
      dx_number { 'dx address' }
      reference { 'Rep Ref' }
      contact_preference { 'fax' }
      email_address { 'test@email.com' }
      fax_number { '0207 345 6789' }
    end
  end
end
