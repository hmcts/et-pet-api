require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_diversity_response_command, class: '::EtApi::Test::Json::Document' do
    trait :full do
      uuid { SecureRandom.uuid }
      command { 'BuildDiversityResponse' }
      data { build(:json_build_diversity_response_data, :full) }
    end
  end

  factory :json_build_diversity_response_data, class: '::EtApi::Test::Json::Node' do
    trait :full do
      claim_type { "Discrimination" }
      sex { "Prefer not to say" }
      sexual_identity { "Gay / Lesbian" }
      age_group { "35-44" }
      ethnicity { "Black / African / Caribbean / Black British" }
      ethnicity_subgroup { "Any other Black / African / Caribbean background" }
      disability { "No" }
      caring_responsibility { "Prefer not to say" }
      gender { "Prefer not to say" }
      gender_at_birth { "Prefer not to say" }
      pregnancy { "Prefer not to say" }
      relationship { "Divorced" }
      religion { "Prefer not to say" }
    end
  end
end
