require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_claimant_data, class: ::EtApi::Test::Json::Document do
    trait :mr_na_o_malley do
      mr_first_last
      first_name { 'n/a' }
      last_name { "O'Malley" }
    end

    trait :mr_na_unicode do
      mr_first_last
      first_name { 'n/a' }
      last_name { "Unicode" }
      mobile_number { "\u202d01234 777666\u202d" }
    end

    trait :mr_first_last do
      title { 'Mr' }
      first_name { 'First' }
      last_name { 'Last' }
      association :address_attributes, :petty_france_102, factory: :json_address_data
      address_telephone_number { '01234 567890' }
      mobile_number { '01234 098765' }
      email_address { 'test@digital.justice.gov.uk' }
      fax_number { nil }
      contact_preference { 'Email' }
      gender { 'Male' }
      date_of_birth { '1982-11-21' }
      special_needs { nil }
    end

    trait :invalid_address_keys do
      association :address_attributes, :invalid_keys, factory: :json_address_data
    end

    trait :tamara_swift do
      title { "Mrs" }
      first_name { "tamara" }
      last_name { "swift" }
      association :address_attributes, factory: :json_address_data,
                                       building: '71088',
                                       street: 'nova loaf',
                                       locality: 'keelingborough',
                                       county: 'hawaii',
                                       post_code: 'yy9a 2la'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1957-07-06' }
      special_needs { nil }
    end

    trait :diana_flatley do
      title { "Mr" }
      first_name { "diana" }
      last_name { "flatley" }
      association :address_attributes, factory: :json_address_data,
                                       building: '66262',
                                       street: 'feeney station',
                                       locality: 'west jewelstad',
                                       county: 'montana',
                                       post_code: 'r8p 0jb'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1986-09-24' }
      special_needs { nil }
    end

    trait :mariana_mccullough do
      title { "Ms" }
      first_name { "mariana" }
      last_name { "mccullough" }
      association :address_attributes, factory: :json_address_data,
                                       building: '819',
                                       street: 'mitchell glen',
                                       locality: 'east oliverton',
                                       county: 'south carolina',
                                       post_code: 'uh2 4na'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1992-08-10' }
      special_needs { nil }
    end

    trait :eden_upton do
      title { "Mr" }
      first_name { "eden" }
      last_name { "upton" }
      association :address_attributes, factory: :json_address_data,
                                       building: '272',
                                       street: 'hoeger lodge',
                                       locality: 'west roxane',
                                       county: 'new mexico',
                                       post_code: 'pd3p 8ns'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1965-01-09' }
      special_needs { nil }
    end

    trait :annie_schulist do
      title { "Miss" }
      first_name { "annie" }
      last_name { "schulist" }
      association :address_attributes, factory: :json_address_data,
                                       building: '3216',
                                       street: 'franecki turnpike',
                                       locality: 'amaliahaven',
                                       county: 'washington',
                                       post_code: 'f3 6nl'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1988-07-19' }
      special_needs { nil }
    end

    trait :thad_johns do
      title { "Mrs" }
      first_name { "thad" }
      last_name { "johns" }
      association :address_attributes, factory: :json_address_data,
                                       building: '66462',
                                       street: 'austyn trafficway',
                                       locality: 'lake valentin',
                                       county: 'new jersey',
                                       post_code: 'rt49 2qa'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1993-06-14' }
      special_needs { nil }
    end

    trait :coleman_kreiger do
      title { "Miss" }
      first_name { "coleman" }
      last_name { "kreiger" }
      association :address_attributes, factory: :json_address_data,
                                       building: '934',
                                       street: 'whitney burgs',
                                       locality: 'emmanuelhaven',
                                       county: 'alaska',
                                       post_code: 'td6b 6jj'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1960-05-12' }
      special_needs { nil }
    end

    trait :jenson_deckow do
      title { "Ms" }
      first_name { "jensen" }
      last_name { "deckow" }
      association :address_attributes, factory: :json_address_data,
                                       building: '1230',
                                       street: 'guiseppe courts',
                                       locality: 'south candacebury',
                                       county: 'arkansas',
                                       post_code: 'u0p 6al'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1970-04-27' }
      special_needs { nil }
    end

    trait :darien_bahringer do
      title { "Mr" }
      first_name { "darien" }
      last_name { "bahringer" }
      association :address_attributes, factory: :json_address_data,
                                       building: '3497',
                                       street: 'wilkinson junctions',
                                       locality: 'kihnview',
                                       county: 'hawaii',
                                       post_code: 'z2e 3wl'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1958-06-29' }
      special_needs { nil }
    end

    trait :eulalia_hammes do
      title { "Mrs" }
      first_name { "eulalia" }
      last_name { "hammes" }
      association :address_attributes, factory: :json_address_data,
                                       building: '376',
                                       street: 'krajcik wall',
                                       locality: 'south ottis',
                                       county: 'idaho',
                                       post_code: 'kg2 5aj'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      fax_number { nil }
      contact_preference { '' }
      gender { '' }
      date_of_birth { '1998-10-04' }
      special_needs { nil }
    end

    trait :minimal do
      title { "Mrs" }
      first_name { "eulalia" }
      last_name { "hammes" }
      date_of_birth { '1998-10-04' }
    end
  end
end
