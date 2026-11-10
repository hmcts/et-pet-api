FactoryBot.define do
  factory :ccd_export_export, class: '::EtApi::Test::Json::Node' do
    transient do
      claim_attrs { {} }
      claim_traits { [:default] }
      response_attrs { {} }
      response_traits { [:default] }
    end
    sequence(:id) { |idx| idx }
    external_system { build(:ccd_export_system) }
    resource { nil }

    trait :for_claim do
      resource { build(:ccd_export_claim, *claim_traits, **claim_attrs) }
      resource_type { 'Claim' }
    end

    trait :for_response do
      resource { build(:ccd_export_response, *response_traits, **response_attrs) }
      resource_type { 'Response' }
    end

    trait :limited_multiples_count do
      external_system { build(:ccd_export_system, :limited_multiples_count) }
    end

    trait :update do
      # Empty block - deliberate - to define an interface
    end
  end
end
