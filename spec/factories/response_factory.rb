FactoryBot.define do
  factory :response do
    date_of_receipt { Time.zone.now }
    case_number '2212345/2016'
    claimants_name 'Joe Strummer'
    sequence :reference do |n|
      "22#{20000000 + n}00"
    end
    association :respondent

    trait :with_representative do
      association :representative, :example_data
    end

    trait :without_representative do
      representative nil
    end

    trait :with_pdf_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_pdf)
      end
    end

    trait :with_text_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_text)
      end
    end

    trait :with_rtf_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_rtf)
      end
    end

    trait :ready_for_export do
      # Ready for export MUST be in the database and files stored - so we dont do build here
      after(:create) do |response, _evaluator|
        Export.create resource: response
      end
    end

    trait :example_data do
      reference "222000000300"
      association :respondent, :example_data
    end
  end
end
