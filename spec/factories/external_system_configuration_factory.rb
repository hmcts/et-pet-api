FactoryBot.define do
  factory :external_system_configuration do
    sequence(:key) {|idx| "key_#{idx}"}
    sequence(:value) {|idx| "value_#{idx}"}
  end
end
