FactoryBot.define do
  factory :external_system do

    trait :atos do
      name "Atos"
      reference "atos"
      office_codes []
      enabled true
    end

    trait :for_all_offices do
      office_codes { Office.pluck(:code) }
    end
  end
end
