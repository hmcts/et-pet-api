FactoryBot.define do
  factory :office do
    code { 99 }
    name { "Default Office" }
    is_default { true }
    address { "102 Petty France, London" }
    telephone { "07777 777777" }
    email { "info@example.com" }
  end
end
