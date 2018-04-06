FactoryBot.define do
  factory :uploaded_file do
    trait :example_pdf do
      filename 'et1_first_last.pdf'
      checksum 'ee2714b8b731a8c1e95dffaa33f89728'
      after(:build) do |uploaded_file, evaluator|
        uploaded_file.file.attach(Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf'))
      end
    end
  end
end