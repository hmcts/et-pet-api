FactoryBot.define do
  factory :export do
    transient do
      external_system_reference { nil }
    end
    trait :ccd do
      external_system_reference { 'ccd_manchester' }
    end

    trait :claim do
      resource { build(:claim) }
    end

    trait :response do
      resource { build(:response) }
    end

    after(:build) do |export, evaluator|
      if evaluator.external_system_reference
        export.external_system = ExternalSystem.find_by_reference! evaluator.external_system_reference
      end
    end
  end
end
