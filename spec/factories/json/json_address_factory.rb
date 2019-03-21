require 'faker'

FactoryBot.define do

  factory :json_address_data, class: ::EtApi::Test::Json::Node do
    trait :empty do
      # Intentionally blank
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

    trait :petty_france_102 do
      building { '102' }
      street { 'Petty France' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'SW1H 9AJ' }
    end

    trait :regent_street_108 do
      building { '108' }
      street { 'Regent Street' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'SW1H 9QR' }
    end

    trait :piccadilly_circus_110 do
      building { '110' }
      street { 'Piccadily Circus' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'SW1H 9ST' }
    end

    trait :mayfair_106 do
      building { '106' }
      street { 'Mayfair' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'SW1H 9PP' }
    end

    # An address that should route to the default office - only post code is really relevant
    trait :for_default_office do
      building { '106' }
      street { 'Mayfair' }
      locality { 'London' }
      county { 'Greater London' }
      post_code { 'FF1 1AA' }
    end

  end
end
