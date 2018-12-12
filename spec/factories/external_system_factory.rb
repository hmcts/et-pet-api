FactoryBot.define do
  factory :external_system do

    trait :atos do
      name { "Atos" }
      reference { "atos" }
      office_codes { [] }
      enabled { true }
    end

    trait :minimal do
      name { "Anything" }
      sequence(:reference) { |idx| "reference#{idx}" }
      office_codes { [] }
      enabled { true }
    end

    trait :for_all_offices do
      office_codes { Office.pluck(:code) }
    end

    trait :ccd_local_test do
      name "CCD"
      sequence(:reference) { |idx| "ccd_instance_#{idx}" }
      enabled true
      for_all_offices
      configurations do
        [
          build(:external_system_configuration,
            key: 'idam_user_token_exchange_url',
            value: 'http://fakeccd.com:4501/idam/testing-support/lease'
          ),
          build(:external_system_configuration,
            key: 'idam_service_token_exchange_url',
            value: 'http://fakeccd.com:4502/idam/testing-support/lease'),
          build(:external_system_configuration,
            key: 'create_case_url',
            value: 'http://fakeccd.com:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases'
          ),
          build(:external_system_configuration,
            key: 'initiate_case_url',
            value: 'http://fakeccd.com:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token'
          ),
          build(:external_system_configuration,key: 'user_id', value: '38'),
          build(:external_system_configuration, key: 'user_role', value: 'caseworker-publiclaw'),
          build(:external_system_configuration, key: 'jurisdiction_id', value: 'PUBLICLAW'),
          build(:external_system_configuration, key: 'case_type_id', value: 'TRIB_MVP_3_TYPE'),
          build(:external_system_configuration, key: 'initiate_case_event_id', value: 'initiateCase')
        ]
      end
    end
  end
end
