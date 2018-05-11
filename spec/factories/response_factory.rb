FactoryBot.define do
  factory :response do
    date_of_receipt { Time.zone.now }
    sequence :reference do |n|
      "22#{20000000 + n}00"
    end
    association :respondent

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
        ResponseExport.create response: response
      end
    end

    trait :example_data do
      reference "222000000300"
      association :respondent, :example_data
    end
  end
end
