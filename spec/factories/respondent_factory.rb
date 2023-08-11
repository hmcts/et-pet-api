FactoryBot.define do
  factory :respondent do
    name { "Respondent Name" }
    address
    association :work_address, factory: :address

    trait :unique_name do
      sequence(:name) { |idx| "Respondent Name#{idx}" }
    end

    trait :example_data do
      name { 'Respondent Name' }
      contact { 'Respondent Contact Name' }
      association :address,
                  factory: :address,
                  building: '108',
                  street: 'Regent Street',
                  locality: 'London',
                  county: 'Greater London',
                  post_code: 'G1 2FF'

      work_address_telephone_number { '03333 423554' }
      address_telephone_number { '02222 321654' }
      acas_certificate_number { 'NE000100/78/90' }
      association :work_address,
                  factory: :address,
                  building: '110',
                  street: 'Piccadily Circus',
                  locality: 'London',
                  county: 'Greater London',
                  post_code: 'SW1H 9ST'
      alt_phone_number { '03333 423554' }
      contact_preference { 'email' }
      email_address { 'john@dodgyco.com' }
      dx_number { 'dx1234567890' }
      fax_number { '02222 222222' }
      allow_video_attendance { true }
      organisation_employ_gb { 10 }
      organisation_more_than_one_site { true }
      employment_at_site_number { 5 }
      disability_information { '' }
      disability { false }
    end

    trait :no_acas_joint_claimant do
      acas_certificate_number { nil }
      acas_exemption_code { 'joint_claimant_has_acas_number' }
    end

    trait :no_acas_no_jurisdiction do
      acas_certificate_number { nil }
      acas_exemption_code { 'acas_has_no_jurisdiction' }
    end

    trait :no_acas_employer_contacted do
      acas_certificate_number { nil }
      acas_exemption_code { 'employer_contacted_acas' }
    end

    trait :no_acas_interim_relief do
      acas_certificate_number { nil }
      acas_exemption_code { 'interim_relief' }
    end

    trait :mr_na_o_malley do
      example_data
      name { "n/a O'Malley" }
    end
  end
end
