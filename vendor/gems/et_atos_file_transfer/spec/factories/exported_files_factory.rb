FactoryBot.define do
  factory :exported_file, class: 'EtAtosFileTransfer::ExportedFile' do
    transient do
      file_path nil
    end

    trait :example_zip_file do
      sequence(:filename) {|n| "example_zip_file_#{n}.zip"}
      file_path { File.absolute_path(File.join('..', 'fixtures', 'example_zip_file.zip'), __dir__) }
    end

    after(:build) do |exported_file, evaluator|
      exported_file.file.attach(Rack::Test::UploadedFile.new(evaluator.file_path))
    end
  end
end
