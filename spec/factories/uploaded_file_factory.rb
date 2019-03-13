FactoryBot.define do
  factory :uploaded_file do
    # @TODO RST-1729 - Remove switching code for upload_method - we will only support direct uploads
    transient do
      upload_method { :url }
      file_to_attach { nil }
    end
    trait :example_pdf do
      filename { 'et1_first_last.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/pdf', filename: Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf') } }
    end

    trait :example_claim_text do
      filename { 'et1_first_last.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/plain', filename: Rails.root.join('spec', 'fixtures', 'et1_first_last.txt') } }
    end

    trait :example_claim_rtf do
      filename { 'et1_attachment_first_last.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf') } }
    end

    trait :example_claim_claimants_text do
      filename { 'et1a_first_last.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/plain', filename: Rails.root.join('spec', 'fixtures', 'et1a_first_last.txt') } }
    end

    trait :example_claim_claimants_csv do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join('spec', 'fixtures', 'simple_user_with_csv_group_claims.csv') } }
    end

    trait :example_claim_claimants_csv_bad_encoding do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join('spec', 'fixtures', 'simple_user_with_csv_group_claims_bad_encoding.csv') } }
    end

    trait :example_response_text do
      filename { 'et3_atos_export.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/plain', filename: Rails.root.join('spec', 'fixtures', 'et3.txt') } }
    end

    trait :example_response_rtf do
      filename { 'et3_atos_export.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf') } }
    end

    trait :example_response_input_rtf do
      filename { 'additional_information.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join('spec', 'fixtures', 'example.rtf') } }
    end

    trait :example_response_wrong_input_rtf do
      filename { 'additional_information.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf') } }
    end

    # We do not have an example pdf yet - but the file contents does not really matter as nothing is reading it
    trait :example_response_pdf do
      filename { 'et3_atos_export.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/pdf', filename: Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf') } }
    end

    trait :example_data do
      example_pdf
    end

    trait :direct_upload do
      upload_method { :direct_upload }
    end

    # @TODO RST-1676 - Remove amazon / azure switcher below
    after(:build) do |uploaded_file, evaluator|
      next if evaluator.file_to_attach.nil?

      service_type = ActiveStorage::Blob.service.class.name =~ /Azure/ ? :azure : :amazon
      service_type = :"#{service_type}_direct_upload" if evaluator.upload_method == :direct_upload
      begin
        file = File.open(evaluator.file_to_attach[:filename], 'rb')
        blob = ActiveStorage::Blob.new filename: File.basename(evaluator.file_to_attach[:filename]),
                                       content_type: evaluator.file_to_attach[:content_type]
        blob.service = ActiveStorage::Service.configure service_type, Rails.configuration.active_storage.service_configurations
        blob.upload(file)
        uploaded_file.file.attach(blob)
      ensure
        file.close
      end
    end
  end
end
