FactoryBot.define do
  factory :export do
    transient do
      external_system_reference { nil }
    end
    trait :ccd do
      external_system_reference { 'ccd_manchester' }
    end

    trait :atos do
      external_system { build(:external_system, :atos) }
    end

    trait :claim do
      resource { build(:claim) }
    end

    trait :response do
      resource { build(:response) }
    end

    after(:build) do |export, evaluator|
      if evaluator.external_system_reference
        export.external_system = ExternalSystem.find_by! reference: evaluator.external_system_reference
      end
    end

    trait :exported do
      transient do
        exported_on { Time.current }
      end
      after(:build) do |export, evaluator|
        export.updated_at = evaluator.exported_on
      end

      to_create { |export, _context| export.save!(touch: false) }
    end
  end
end
