require 'builder'
module EtApi
  module Test
    module XML
      class Node < OpenStruct
        def as_json
          to_h.inject({}) do |acc, (k, v)|
            acc[k.to_s.camelize] = normalize(v)
            acc
          end
        end

        private

        def normalize(value)
          case value
          when String then value
          when Node then value.as_json
          when Array then value.map { |i| normalize(i) }
          when nil then ::EtApi::Test::XML::NilNode.new
          else value
          end
        end
      end

      class Document < Node

        def to_xml(builder: ::Builder::XmlMarkup.new(indent: 2, explicit_nil_handling: false))
          builder.tag! 'ETFeesEntry', xmlns: 'http://www.justice.gov.uk/ETFEES', 'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation': 'ETFees_v0.24.xsd' do
            as_json.each { |key, value| ActiveSupport::XmlMini.to_tag(key, value, builder: builder, skip_types: true) }
          end
        end
      end

      class NilNode
        def to_xml(root:, builder:, **_args)
          builder.tag!(root, nil, {})
        end
      end
    end
  end
end
FactoryBot.define do
  claimants_list = [
    :mr_first_last,
    :tamara_swift,
    :diana_flatley,
    :mariana_mccullough,
    :eden_upton,
    :annie_schulist,
    :thad_johns,
    :coleman_kreiger,
    :jenson_deckow,
    :darien_bahringer,
    :eulalia_hammes
  ]
  respondents_list = [
    :respondent_name,
    :carlos_mills,
    :felicity_schuster,
    :glennie_satterfield,
    :romaine_rowe
  ]
  representatives_list = [
    :solicitor_name
  ]

  factory :xml_claim, class: ::EtApi::Test::XML::Document do
    initialize_with do
      new(attributes)
    end

    transient do
      number_of_claimants 1
      number_of_respondents 1
      number_of_representatives 1
    end

    association :document_id, factory: :xml_claim_document_id
    sequence :fee_group_reference do |idx|
      "#{2220000000 + idx}00"
    end
    submission_urn 'J704-ZK5E'
    current_quantity_of_claimants '1'
    submission_channel 'Web'
    case_type 'Single'
    jurisdiction '2'
    office_code '22'
    date_of_receipt_et { Time.zone.now.strftime('%Y-%m-%dT%H:%M:%S%z') }
    remission_indicated 'NotRequested'
    administrator '-1'
    association :payment, :zero, factory: :xml_claim_payment
    files do
      [build(:xml_claim_file, :et1_first_last_pdf)]
    end

    after(:build) do |r, evaluator|
      unless r.claimants.is_a?(Array)
        r.claimants = []
        evaluator.number_of_claimants.times do |idx|
          r.claimants << build(:xml_claimant, claimants_list[idx % claimants_list.length])
        end
      end

      unless r.respondents.is_a?(Array)
        r.respondents = []
        evaluator.number_of_respondents.times do |idx|
          r.respondents << build(:xml_claim_respondent, respondents_list[idx % respondents_list.length])
        end
      end

      unless r.representatives.is_a?(Array)
        r.representatives = []
        evaluator.number_of_representatives.times do |idx|
          r.representatives << build(:xml_claim_representative, representatives_list[idx % representatives_list.length])
        end
      end
    end

    trait(:simple_user) do
      association :document_id, factory: :xml_claim_document_id
      fee_group_reference '222000000300'
      submission_urn 'J704-ZK5E'
      current_quantity_of_claimants '1'
      submission_channel 'Web'
      case_type 'Single'
      jurisdiction '2'
      office_code '22'
      date_of_receipt_et '2018-03-29T16:46:26+01:00'
      remission_indicated 'NotRequested'
      administrator '-1'
      claimants do
        [build(:xml_claimant, :mr_first_last)]
      end
      respondents do
        [build(:xml_claim_respondent, :respondent_name)]
      end
      representatives do
        [build(:xml_claim_representative, :solicitor_name)]
      end
      association :payment, :zero, factory: :xml_claim_payment
      files do
        [build(:xml_claim_file, :et1_first_last_pdf)]
      end
    end

    trait(:simple_user_with_csv) do
      simple_user
      with_csv
    end

    trait :with_csv do
      case_type 'Multiple'
      claimants do
        [
          build(:xml_claimant, :mr_first_last),
          build(:xml_claimant, :tamara_swift),
          build(:xml_claimant, :diana_flatley),
          build(:xml_claimant, :mariana_mccullough),
          build(:xml_claimant, :eden_upton),
          build(:xml_claimant, :annie_schulist),
          build(:xml_claimant, :thad_johns),
          build(:xml_claimant, :coleman_kreiger),
          build(:xml_claimant, :jenson_deckow),
          build(:xml_claimant, :darien_bahringer),
          build(:xml_claimant, :eulalia_hammes)
        ]
      end
      files do
        [
          build(:xml_claim_file, :et1_first_last_pdf),
          build(:xml_claim_file, :simple_user_with_csv_group_claims)
        ]
      end
    end

    trait :simple_user_with_rtf do
      simple_user
      with_rtf
    end

    trait :with_rtf do
      files do
        [
          build(:xml_claim_file, :et1_first_last_pdf),
          build(:xml_claim_file, :simple_user_with_rtf)
        ]
      end
    end
  end

  factory :xml_claim_document_id, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    document_name 'ETFeesEntry'
    unique_id '20180329164627'
    document_type 'ETFeesEntry'
    time_stamp '2018-03-29T16:46:27+01:00'
    version '1'

  end

  factory :xml_claimant, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :sequenced do

    end

    trait :mr_first_last do
      group_contact 'true'
      title 'Mr'
      forename 'First'
      surname 'Last'
      association :address, :petty_france_102, factory: :xml_claim_address
      office_number '01234 567890'
      alt_phone_number '01234 098765'
      email 'test@digital.justice.gov.uk'
      fax nil
      preferred_contact_method 'Email'
      sex 'Male'
      date_of_birth '21/11/1982'
    end

    trait :tamara_swift do
      group_contact 'false'
      title "Mrs"
      forename "tamara"
      surname "swift"
      association :address, factory: :xml_claim_address,
                            line: '71088',
                            street: 'nova loaf',
                            town: 'keelingborough',
                            county: 'hawaii',
                            postcode: 'yy9a 2la'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '06/07/1957'
    end

    trait :diana_flatley do
      group_contact 'false'
      title "Mr"
      forename "diana"
      surname "flatley"
      association :address, factory: :xml_claim_address,
                            line: '66262',
                            street: 'feeney station',
                            town: 'west jewelstad',
                            county: 'montana',
                            postcode: 'r8p 0jb'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '24/09/1986'
    end

    trait :mariana_mccullough do
      group_contact 'false'
      title "Ms"
      forename "mariana"
      surname "mccullough"
      association :address, factory: :xml_claim_address,
                            line: '819',
                            street: 'mitchell glen',
                            town: 'east oliverton',
                            county: 'south carolina',
                            postcode: 'uh2 4na'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '10/08/1992'
    end

    trait :eden_upton do
      group_contact 'false'
      title "Mr"
      forename "eden"
      surname "upton"
      association :address, factory: :xml_claim_address,
                            line: '272',
                            street: 'hoeger lodge',
                            town: 'west roxane',
                            county: 'new mexico',
                            postcode: 'pd3p 8ns'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '09/01/1965'
    end

    trait :annie_schulist do
      group_contact 'false'
      title "Miss"
      forename "annie"
      surname "schulist"
      association :address, factory: :xml_claim_address,
                            line: '3216',
                            street: 'franecki turnpike',
                            town: 'amaliahaven',
                            county: 'washington',
                            postcode: 'f3 6nl'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '19/07/1988'
    end

    trait :thad_johns do
      group_contact 'false'
      title "Mrs"
      forename "thad"
      surname "johns"
      association :address, factory: :xml_claim_address,
                            line: '66462',
                            street: 'austyn trafficway',
                            town: 'lake valentin',
                            county: 'new jersey',
                            postcode: 'rt49 2qa'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '14/06/1993'
    end

    trait :coleman_kreiger do
      group_contact 'false'
      title "Miss"
      forename "coleman"
      surname "kreiger"
      association :address, factory: :xml_claim_address,
                            line: '934',
                            street: 'whitney burgs',
                            town: 'emmanuelhaven',
                            county: 'alaska',
                            postcode: 'td6b 6jj'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '12/05/1960'
    end

    trait :jenson_deckow do
      title "Ms"
      forename "jensen"
      surname "deckow"
      association :address, factory: :xml_claim_address,
                            line: '1230',
                            street: 'guiseppe courts',
                            town: 'south candacebury',
                            county: 'arkansas',
                            postcode: 'u0p 6al'
      office_number ''
      alt_phone_number ''
      email ''
      preferred_contact_method ''
      sex ''
      date_of_birth '27/04/1970'
    end

    trait :darien_bahringer do
      group_contact 'false'
      title "Mr"
      forename "darien"
      surname "bahringer"
      association :address, factory: :xml_claim_address,
                            line: '3497',
                            street: 'wilkinson junctions',
                            town: 'kihnview',
                            county: 'hawaii',
                            postcode: 'z2e 3wl'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '29/06/1958'
    end

    trait :eulalia_hammes do
      group_contact 'false'
      title "Mrs"
      forename "eulalia"
      surname "hammes"
      association :address, factory: :xml_claim_address,
                            line: '376',
                            street: 'krajcik wall',
                            town: 'south ottis',
                            county: 'idaho',
                            postcode: 'kg2 5aj'
      office_number ''
      alt_phone_number ''
      email ''
      fax nil
      preferred_contact_method ''
      sex ''
      date_of_birth '04/10/1998'
    end
  end

  factory :xml_claim_respondent, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    group_contact 'true'
    name 'Respondent Name'
    association :address, :regent_street_108, factory: :xml_claim_address
    office_number '03333 423554'
    phone_number '02222 321654'
    association :acas, :ac1234567890, factory: :xml_claim_acas
    association :alt_address, :piccadilly_circus_110, factory: :xml_claim_address
    alt_phone_number '03333 423554'

    trait :respondent_name do
      group_contact 'true'
      name 'Respondent Name'
      association :address, :regent_street_108, factory: :xml_claim_address
      office_number '03333 423554'
      phone_number '02222 321654'
      association :acas, :ac1234567890, factory: :xml_claim_acas
      association :alt_address, :piccadilly_circus_110, factory: :xml_claim_address
      alt_phone_number '03333 423554'
    end

    trait :carlos_mills do
      group_contact 'false'
      name 'Carlos Mills'
      association :address,
        factory: :xml_claim_address,
        line: "255", street: "Crooks Light", town: "Watersburgh", county: "East Sussex", postcode: "KV8B 6LP"

      office_number '0979 399 5059'
      phone_number '07628 465233'
      association :acas, :ac1234567890, factory: :xml_claim_acas
      association :alt_address, :piccadilly_circus_110, factory: :xml_claim_address
      alt_phone_number '0979 399 5059'
    end

    trait :felicity_schuster do
      group_contact 'false'
      name 'Felicity Schuster'
      association :address,
        factory: :xml_claim_address,
        line: "988", street: "Purdy Via", town: "Erdmanville", county: "Warwickshire", postcode: "GK40 1RL"

      office_number '0121 334 0437'
      phone_number '07754 870360'
      association :acas, :ac1234567890, factory: :xml_claim_acas
      association :alt_address, :piccadilly_circus_110, factory: :xml_claim_address
      alt_phone_number '0121 334 0437'
    end

    trait :glennie_satterfield do
      group_contact 'false'
      name 'Glennie Satterfield'
      association :address,
        factory: :xml_claim_address,
        line: "6380", street: "Noah Burg", town: "South Bellashire", county: "Humberside", postcode: "W9G 4XJ"

      office_number '0826 692 1241'
      phone_number '07761 628758'
      association :acas, :ac1234567890, factory: :xml_claim_acas
      association :alt_address, :piccadilly_circus_110, factory: :xml_claim_address
      alt_phone_number '0826 692 1241'
    end

    trait :romaine_rowe do
      group_contact 'false'
      name 'Romaine Rowe'
      association :address,
        factory: :xml_claim_address,
        line: "189", street: "Schaefer Heights", town: "New Bettyfurt", county: "Kent", postcode: "W6 2HU"

      office_number '0111 786 1278'
      phone_number '07862 372522'
      association :acas, :ac1234567890, factory: :xml_claim_acas
      association :alt_address, :piccadilly_circus_110, factory: :xml_claim_address
      alt_phone_number '0111 786 1278'
    end
  end

  factory :xml_claim_address, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :petty_france_102 do
      line '102'
      street 'Petty France'
      town 'London'
      county 'Greater London'
      postcode 'SW1H 9AJ'
    end

    trait :regent_street_108 do
      line '108'
      street 'Regent Street'
      town 'London'
      county 'Greater London'
      postcode 'SW1H 9QR'
    end

    trait :piccadilly_circus_110 do
      line '110'
      street 'Piccadily Circus'
      town 'London'
      county 'Greater London'
      postcode 'SW1H 9ST'
    end

    trait :mayfair_106 do
      line '106'
      street 'Mayfair'
      town 'London'
      county 'Greater London'
      postcode 'SW1H 9PP'
    end
  end

  factory :xml_claim_acas, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :ac1234567890 do
      number 'AC123456/78/90'
    end
  end

  factory :xml_claim_representative, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :solicitor_name do
      name 'Solicitor Name'
      organisation 'Solicitors Are Us Fake Company'
      association :address, :mayfair_106, factory: :xml_claim_address
      office_number '01111 123456'
      alt_phone_number '02222 654321'
      email 'solicitor.test@digital.justice.gov.uk'
      claimant_or_respondent 'C'
      type 'Solicitor'
      d_x_number 'dx1234567890'
    end
  end

  factory :xml_claim_payment, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :zero do
      association :fee, :zero, factory: :xml_claim_payment_fee
    end
  end

  factory :xml_claim_payment_fee, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :zero do
      amount '0'
      p_r_n '222000000300'
      date '2018-03-29T16:46:26+01:00'
    end
  end

  factory :xml_claim_file, class: ::EtApi::Test::XML::Node do
    initialize_with do
      new(attributes)
    end

    trait :et1_first_last_pdf do
      filename 'et1_first_last.pdf'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
    end

    trait :simple_user_with_csv_group_claims do
      filename 'simple_user_with_csv_group_claims.csv'
      checksum '7ac66d9f4af3b498e4cf7b9430974618'
    end

    trait :simple_user_with_rtf do
      filename 'simple_user_with_rtf.rtf'
      checksum 'e69a0344620b5040b7d0d1595b9c7726'
    end
  end
end
