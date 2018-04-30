FactoryBot.define do
  factory :respondent do
    name "Respondent Name"
    address
    association :work_address, factory: :address

    trait :example_data do
      name 'Respondent Name'
      association :address,
        factory: :address,
        building: '108',
        street: 'Regent Street',
        locality: 'London',
        county: 'Greater London',
        post_code: 'SW1H 9QR'

      work_address_telephone_number '03333 423554'
      address_telephone_number '02222 321654'
      acas_number 'AC123456/78/90'
      association :work_address,
        factory: :address,
        building: '110',
        street: 'Piccadily Circus',
        locality: 'London',
        county: 'Greater London',
        post_code: 'SW1H 9ST'
      alt_phone_number '03333 423554'
    end
  end
end
