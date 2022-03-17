FactoryBot.define do
  factory :json_validate_claimants_file_command, class: ::EtApi::Test::Json::Document do
    uuid { SecureRandom.uuid }
    command { 'ValidateClaimantsFile' }

    trait :valid do
      data { build(:json_file_data, :simple_user_with_csv_group_claims) }
    end

    trait :missing do
      data { build(:json_file_data, :simple_user_with_csv_group_claims, data_from_key: 'wrongvalue', upload_method: :dont_upload) }
    end

    trait :empty do
      data { build(:json_file_data, :empty_csv) }
    end

    trait :missing_column do
      data { build(:json_file_data, :simple_user_with_csv_group_claims_missing_column) }
    end

    trait :invalid do
      data { build(:json_file_data, :simple_user_with_csv_group_claims_multiple_errors) }
    end
  end
end
