FactoryBot.define do
  factory :representative do
    name { "Solicitor Name" }
    address

    trait :example_data do
      name { 'Solicitor Name' }
      organisation_name { 'Solicitors Are Us Fake Company' }
      association :address,
        building: '106',
        street: 'Mayfair',
        locality: 'London',
        county: 'Greater London',
        post_code: 'SW1H 9PP'

      address_telephone_number { '01111 123456' }
      mobile_number { '02222 654321' }
      email_address { 'solicitor.test@digital.justice.gov.uk' }
      representative_type { 'Solicitor' }
      dx_number { 'dx1234567890' }
      reference { 'solicitor-reference' }
      contact_preference { 'email' }
      fax_number { '02222 222222' }
    end
  end
end
