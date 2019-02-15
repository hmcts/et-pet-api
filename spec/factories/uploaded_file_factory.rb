FactoryBot.define do
  factory :uploaded_file do
    trait :example_pdf do
      filename { 'et1_first_last.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf'))
      end
    end

    trait :example_claim_text do
      filename { 'et1_first_last.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.txt'), 'text/plain'))
      end
    end

    trait :example_claim_rtf do
      filename { 'et1_attachment_first_last.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf'), 'application/rtf'))
      end
    end

    trait :example_claim_claimants_text do
      filename { 'et1a_first_last.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1a_first_last.txt'), 'text/plain'))
      end
    end

    trait :example_claim_claimants_csv do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_csv_group_claims.csv'), 'text/csv'))
      end
    end

    trait :example_claim_claimants_csv_bad_encoding do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_csv_group_claims_bad_encoding.csv'), 'text/csv'))
      end
    end

    trait :example_response_text do
      filename { 'et3_atos_export.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et3.txt'), 'text/plain'))
      end
    end

    trait :example_response_rtf do
      filename { 'et3_atos_export.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf'), 'application/rtf'))
      end
    end

    trait :example_response_input_rtf do
      filename { 'additional_information.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'example.rtf'), 'application/rtf'))
      end
    end

    trait :example_response_wrong_input_rtf do
      filename { 'additional_information.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf'), 'application/rtf'))
      end
    end

    # We do not have an example pdf yet - but the file contents does not really matter as nothing is reading it
    trait :example_response_pdf do
      filename { 'et3_atos_export.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf'))
      end
    end

    trait :example_data do
      example_pdf
    end
  end
end
