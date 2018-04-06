FactoryBot.define do
  factory :claimant do
    first_name "First"
    sequence(:last_name) { |idx| "Lastname#{idx}" }
    association :address
  end
end