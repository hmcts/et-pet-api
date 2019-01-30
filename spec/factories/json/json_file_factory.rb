require 'faker'

FactoryBot.define do

  factory :json_file_data, class: ::EtApi::Test::Json::Node do
    data_url { nil }
    trait :et1_first_last_pdf do
      filename { 'et1_first_last.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      data_from_key { nil }
      after(:build) do |obj, _e|
        uploaded_file = create(:uploaded_file, :example_pdf)
        obj.data_url = uploaded_file.file.blob.service_url
      end
    end

    trait :simple_user_with_csv_group_claims do
      filename { 'simple_user_with_csv_group_claims.csv' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      data_from_key { nil }
      after(:build) do |obj, _e|
        uploaded_file = create(:uploaded_file, :example_claim_claimants_csv)
        obj.data_url = uploaded_file.file.blob.service_url
      end
    end

    trait :simple_user_with_csv_group_claims_uppercased do
      filename { 'simple_user_with_csv_group_claims.CSV' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      data_from_key { nil }
      after(:build) do |obj, _e|
        uploaded_file = create(:uploaded_file, :example_claim_claimants_csv)
        obj.data_url = uploaded_file.file.blob.service_url
      end
    end

    trait :simple_user_with_rtf do
      filename { 'simple_user_with_rtf.rtf' }
      checksum { 'e69a0344620b5040b7d0d1595b9c7726' }
      data_from_key { nil }
      after(:build) do |obj, _e|
        uploaded_file = create(:uploaded_file, :example_claim_rtf)
        obj.data_url = uploaded_file.file.blob.service_url
      end
    end

    trait :simple_user_with_rtf_uppercased do
      filename { 'simple_user_with_rtf.RTF' }
      checksum { 'e69a0344620b5040b7d0d1595b9c7726' }
      data_from_key { nil }
      after(:build) do |obj, _e|
        uploaded_file = create(:uploaded_file, :example_claim_rtf)
        obj.data_url = uploaded_file.file.blob.service_url
      end
    end
  end
end
