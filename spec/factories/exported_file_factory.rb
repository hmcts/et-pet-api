FactoryBot.define do
  factory :exported_file do
    external_system { build(:external_system, :minimal) }
  end
end
