FactoryBot.define do
  factory :external_system do

    trait :atos do
      name { "Atos" }
      reference { "atos" }
      office_codes { [] }
      enabled { true }
      export { false }
    end

    trait :minimal do
      name { "Anything" }
      sequence(:reference) { |idx| "reference#{idx}" }
      office_codes { [] }
      enabled { true }
      export { false }
    end
    
    trait :ccd do
      name { "CCD" }
      reference { "ccd_manchester" }
      office_codes { [] }
      enabled { true }
      export { true }
      export_queue { 'external_system_ccd' }
    end

    trait :for_all_offices do
      office_codes { Office.pluck(:code) }
    end
  end
end
