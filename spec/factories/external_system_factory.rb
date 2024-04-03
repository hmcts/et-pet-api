FactoryBot.define do
  factory :external_system do

    trait :minimal do
      name { "Anything" }
      sequence(:reference) { |idx| "reference#{idx}" }
      office_codes { [] }
      enabled { true }
      export_claims { false }
    end

    trait :atos do
      for_all_offices
      name { "ATOS Secondary" }
      reference { "atos_secondary" }
      enabled { true }
      export_claims { false }
      export_responses { false }
      always_save_export { true }
    end

    trait :ccd do
      name { "CCD" }
      reference { "ccd_manchester" }
      office_codes { [] }
      enabled { true }
      export_claims { true }
      export_queue { 'external_system_ccd' }
    end

    trait :for_all_offices do
      office_codes { Office.pluck(:code) }
    end
  end
end
