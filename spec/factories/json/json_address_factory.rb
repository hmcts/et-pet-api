require 'faker'

FactoryBot.define do

  factory :json_address_data, class: '::EtApi::Test::Json::Node' do
    trait :empty do
      # Intentionally blank
    end

    trait :in_uk do
      country { "United Kingdom" }
    end

    trait :invalid_keys do
      wrong_key { '21' }
      street { "downing_street" }
      locality { "westminster" }
      county { "" }
      post_code { "wc1 1aa" }
    end

    trait :the_shard do
      building { "the_shard" }
      street { "downing_street" }
      locality { "westminster" }
      county { "" }
      post_code { "wc1 1aa" }
    end

    trait :rep_address do
      building { 'Rep Building' }
      street { 'Rep Street' }
      locality { 'Rep Town' }
      county { 'Rep County' }
      post_code { 'WC2 2BB' }
    end

    trait :petty_france102 do
      building { '102' }
      street { 'Petty France' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'SW1H 9AJ' }
    end

    # An address that should route to the default office - only post code is really relevant
    trait :for_default_office do
      building { '106' }
      street { 'Mayfair' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'FF1 1AA' }
    end

    trait :for_manchester_office do
      building { '106' }
      street { 'Manc Street' }
      locality { 'Manchester' }
      county { 'Greater MAnchester' }
      post_code { 'M1 1AQ' }
    end

  end
end
