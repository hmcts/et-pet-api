FactoryBot.define do
  factory :ccd_export_system, class: '::EtApi::Test::Json::Node' do
    sequence(:name) { |idx| "CCD Instance #{idx}" }
    sequence(:reference) { |idx| "ccd_instance_#{idx}" }
    office_codes { [1, 2, 3, 4, 5] }
    export_feedback_queue { 'export_feedback_queue' }
    enabled { true }
    configurations do
      [
        build(:ccd_export_system_configuration, key: 'case_type_id', value: 'Manchester'),
        build(:ccd_export_system_configuration, key: 'multiples_case_type_id', value: 'Manchester_Multiples'),
        build(:ccd_export_system_configuration, key: 'send_request_id', value: 'true'),
        build(:ccd_export_system_configuration, key: 'extra_headers', value: { test_header: 'true' }.to_json)
      ]
    end
    trait :auto_accept_multiples do
      configurations do
        [
          build(:ccd_export_system_configuration, key: 'case_type_id', value: 'Manchester'),
          build(:ccd_export_system_configuration, key: 'multiples_case_type_id', value: 'Manchester_Multiples'),
          build(:ccd_export_system_configuration, key: 'multiples_auto_accept', value: 'true'),
          build(:ccd_export_system_configuration, key: 'send_request_id', value: 'true'),
          build(:ccd_export_system_configuration, key: 'extra_headers', value: { test_header: 'true' }.to_json)
        ]
      end
    end

    trait :limited_multiples_count do
      configurations do
        [
          build(:ccd_export_system_configuration, key: 'case_type_id', value: 'Manchester'),
          build(:ccd_export_system_configuration, key: 'multiples_case_type_id', value: 'Manchester_Multiples'),
          build(:ccd_export_system_configuration, key: 'multiples_max_claimant_count', value: '1')
        ]
      end
    end
  end
end
