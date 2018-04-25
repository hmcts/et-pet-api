FactoryBot.define do
  factory :uploaded_file do
    trait :example_pdf do
      filename 'et1_first_last.pdf'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf'))
      end
    end

    trait :example_xml do
      filename 'et1_first_last.xml'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user.xml'), 'text/xml'))
      end
    end

    trait :example_claim_text do
      filename 'et1_first_last.txt'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.txt'), 'text/plain'))
      end
    end

    trait :example_claim_claimants_text do
      filename 'et1a_first_last.txt'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1a_first_last.txt'), 'text/plain'))
      end
    end

    trait :example_claim_claimants_csv do
      filename 'et1a_first_last.csv'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
      after(:build) do |uploaded_file, _evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_csv_group_claims.csv'), 'text/csv'))
      end
    end

    trait :example_data do
      example_pdf
    end
  end
end
