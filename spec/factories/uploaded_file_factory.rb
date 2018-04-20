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
  end
end
