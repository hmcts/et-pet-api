require 'faker'

FactoryBot.define do

  factory :json_file_data, class: ::EtApi::Test::Json::Node do
    transient do
      upload_method { :url }
      uploaded_file_traits { [] }
    end

    data_url { nil }
    data_from_key { nil }

    trait :et1_first_last_pdf do
      filename { 'et1_first_last.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      uploaded_file_traits { [:example_pdf] }
    end

    trait :simple_user_with_csv_group_claims do
      filename { 'simple_user_with_csv_group_claims.csv' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      uploaded_file_traits { [:example_claim_claimants_csv] }
    end

    trait :empty_csv do
      filename { 'simple_user_with_csv_group_claims.csv' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      uploaded_file_traits { [:empty_csv] }
    end

    trait :simple_user_with_csv_group_claims_missing_column do
      filename { 'simple_user_with_csv_group_claims.csv' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      uploaded_file_traits { [:example_claim_claimants_csv_missing_column] }
    end

    trait :simple_user_with_csv_group_claims_bad_encoding do
      filename { 'simple_user_with_csv_group_claims.csv' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      uploaded_file_traits { [:example_claim_claimants_csv_bad_encoding] }
    end

    trait :simple_user_with_csv_group_claims_multiple_errors do
      filename { 'simple_user_with_csv_group_claims_multiple_errors.csv' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      uploaded_file_traits { [:example_claim_claimants_csv_multiple_errors] }
    end

    trait :simple_user_with_csv_group_claims_uppercased do
      filename { 'simple_user_with_csv_group_claims.CSV' }
      checksum { '7ac66d9f4af3b498e4cf7b9430974618' }
      uploaded_file_traits { [:example_claim_claimants_csv] }
    end

    trait :simple_user_with_rtf do
      filename { 'simple_user_with_rtf.rtf' }
      checksum { 'e69a0344620b5040b7d0d1595b9c7726' }
      uploaded_file_traits { [:example_claim_rtf] }
    end

    trait :simple_user_with_rtf_uppercased do
      filename { 'simple_user_with_rtf.RTF' }
      checksum { 'e69a0344620b5040b7d0d1595b9c7726' }
      uploaded_file_traits { [:example_claim_rtf] }
    end

    trait :direct_upload do
      upload_method { :direct_upload }
    end

    # @TODO RST-1729 Remove the upload method switching as it will always be azure from now on
    after(:build) do |obj, evaluator|
      next unless evaluator.upload_method == :url

      uploaded_file = create(:uploaded_file, *evaluator.uploaded_file_traits)
      obj.data_url = uploaded_file.file.blob.service_url
    end

    after(:build) do |obj, evaluator|
      next unless evaluator.upload_method == :direct_upload

      uploaded_file = create(:uploaded_file, :direct_upload, *evaluator.uploaded_file_traits)
      obj.data_from_key = uploaded_file.file.blob.key
    end
  end
end
