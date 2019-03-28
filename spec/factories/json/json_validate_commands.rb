FactoryBot.define do
  factory :json_validate_claimants_file_command, class: ::EtApi::Test::Json::Document do
    uuid { SecureRandom.uuid }
    command { 'ValidateClaimantsFile' }

    trait :valid do
      data { build(:json_file_data, :simple_user_with_csv_group_claims, upload_method: :direct_upload) }
    end

    trait :missing do
      data { build(:json_file_data, :simple_user_with_csv_group_claims, data_from_key: 'wrongvalue', upload_method: :dont_upload) }
    end

    trait :empty do
      data { build(:json_file_data, :empty_csv, upload_method: :direct_upload) }
    end

    trait :missing_column do
      data { build(:json_file_data, :simple_user_with_csv_group_claims_missing_column, upload_method: :direct_upload) }
    end

    trait :invalid_encoding do
      data { build(:json_file_data, :simple_user_with_csv_group_claims_bad_encoding, upload_method: :direct_upload) }
    end

    trait :invalid do
      data { build(:json_file_data, :simple_user_with_csv_group_claims_multiple_errors, upload_method: :direct_upload) }
    end
  end
end
