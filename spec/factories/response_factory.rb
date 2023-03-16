FactoryBot.define do
  factory :response do
    transient do
      ready_for_export_to { [] }
      additional_information_key { nil }
    end
    date_of_receipt { Time.zone.now }
    case_number { '2212345/2016' }
    claimants_name { 'Joe Strummer' }
    employment_start { Time.zone.parse('1 January 2014') }
    employment_end { Time.zone.parse('31 December 2014') }
    queried_pay_before_tax { 2000 }
    queried_pay_before_tax_period { 'Monthly' }
    queried_take_home_pay { 1500 }
    queried_take_home_pay_period { 'Monthly' }
    disagree_conciliation_reason { '' }
    disagree_employment { '' }
    queried_hours { 30 }
    disagree_claimant_notice_reason { '' }
    disagree_claimant_pension_benefits_reason { '' }
    defend_claim { false }
    defend_claim_facts { '' }
    claim_information { '' }
    agree_with_employment_dates { true }
    agree_with_claimants_description_of_job_or_title { true }
    agree_with_claimants_hours { true }
    agree_with_earnings_details { true }
    agree_with_claimant_notice { true }
    agree_with_claimant_pension_benefits { true }
    pdf_template_reference { 'et3-v2-en' }
    email_template_reference { 'et3-v1-en' }

    sequence :reference do |n|
      "22#{20000000 + n}00"
    end
    association :respondent
    association :office, code: 22

    trait :with_representative do
      association :representative, :example_data
    end

    trait :without_representative do
      representative { nil }
    end

    trait :with_pdf_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_pdf, :system_file_scope)
      end
    end

    trait :with_text_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_text, :system_file_scope)
      end
    end

    trait :with_output_additional_information_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_additional_information, :system_file_scope)
      end
    end

    trait :with_input_rtf_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_input_rtf, :user_file_scope)
        response.uploaded_files << build(:uploaded_file, :example_response_input_additional_information, :system_file_scope)
      end
    end

    trait :with_wrong_input_rtf_file do
      after(:build) do |response, _evaluator|
        response.uploaded_files << build(:uploaded_file, :example_response_wrong_input_rtf, :user_file_scope)
      end
    end

    after(:create) do |response, evaluator|
      evaluator.ready_for_export_to.each do |external_system_id|
        Export.create resource: response, external_system_id: external_system_id
      end
    end

    trait :example_data do
      reference { "222000000300" }
      association :respondent, :example_data
    end

    trait :broken_with_files_missing do
      example_data
    end

    trait :with_command do
      after(:build) do |instance, evaluator|
        instance.commands = [build(:build_response_command, :from_db, db_source: instance, additional_information_key: evaluator.additional_information_key)]
      end
    end
  end
end
