FactoryBot.define do
  factory :claimant do
    first_name { "First" }
    sequence(:last_name) { |idx| "Lastname#{idx}" }
    address

    trait :example_data do
      title { "Mr" }
      first_name { "First" }
      last_name { "Last" }
      association :address,
        building: '102',
        street: 'Petty France',
        locality: 'London',
        county: 'Greater London',
        post_code: 'SW1H 9AJ'
      address_telephone_number { '01234 567890' }
      mobile_number { '01234 098765' }
      email_address { 'test@digital.justice.gov.uk' }
      contact_preference { 'Email' }
      gender { 'Male' }
      date_of_birth { Date.parse('21/11/1982') }
    end

    trait :tamara_swift do
      title { "Mrs" }
      first_name { "tamara" }
      last_name { "swift" }
      association :address,
        building: '71088',
        street: 'nova loaf',
        locality: 'keelingborough',
        county: 'hawaii',
        post_code: 'yy9a 2la'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('06/07/1957') }
    end

    trait :diana_flatley do
      title { "Mr" }
      first_name { "diana" }
      last_name { "flatley" }
      association :address,
        building: '66262',
        street: 'feeney station',
        locality: 'west jewelstad',
        county: 'montana',
        post_code: 'r8p 0jb'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('24/09/1986') }
    end

    trait :mariana_mccullough do
      title { "Ms" }
      first_name { "mariana" }
      last_name { "mccullough" }
      association :address,
        building: '819',
        street: 'mitchell glen',
        locality: 'east oliverton',
        county: 'south carolina',
        post_code: 'uh2 4na'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('10/08/1992') }
    end

    trait :eden_upton do
      title { "Mr" }
      first_name { "eden" }
      last_name { "upton" }
      association :address,
        building: '272',
        street: 'hoeger lodge',
        locality: 'west roxane',
        county: 'new mexico',
        post_code: 'pd3p 8ns'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('09/01/1965') }
    end

    trait :annie_schulist do
      title { "Miss" }
      first_name { "annie" }
      last_name { "schulist" }
      association :address,
        building: '3216',
        street: 'franecki turnpike',
        locality: 'amaliahaven',
        county: 'washington',
        post_code: 'f3 6nl'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('19/07/1988') }
    end

    trait :thad_johns do
      title { "Mrs" }
      first_name { "thad" }
      last_name { "johns" }
      association :address,
        building: '66462',
        street: 'austyn trafficway',
        locality: 'lake valentin',
        county: 'new jersey',
        post_code: 'rt49 2qa'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('14/06/1993') }
    end

    trait :coleman_kreiger do
      title { "Miss" }
      first_name { "coleman" }
      last_name { "kreiger" }
      association :address,
        building: '934',
        street: 'whitney burgs',
        locality: 'emmanuelhaven',
        county: 'alaska',
        post_code: 'td6b 6jj'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('12/05/1960') }
    end

    trait :jenson_deckow do
      title { "Ms" }
      first_name { "jensen" }
      last_name { "deckow" }
      association :address,
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
      date_of_birth { Date.parse('27/04/1970') }
    end

    trait :darien_bahringer do
      title { "Mr" }
      first_name { "darien" }
      last_name { "bahringer" }
      association :address,
        building: '3497',
        street: 'wilkinson junctions',
        locality: 'kihnview',
        county: 'hawaii',
        post_code: 'z2e 3wl'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('29/06/1958') }
    end

    trait :eulalia_hammes do
      title { "Mrs" }
      first_name { "eulalia" }
      last_name { "hammes" }
      association :address,
        building: '376',
        street: 'krajcik wall',
        locality: 'south ottis',
        county: 'idaho',
        post_code: 'kg2 5aj'
      address_telephone_number { '' }
      mobile_number { '' }
      email_address { '' }
      contact_preference { '' }
      gender { '' }
      date_of_birth { Date.parse('04/10/1998') }
    end

    trait :mr_na_o_malley do
      darien_bahringer
      first_name { 'n/a' }
      last_name { "O'Malley" }
    end
  end
end
