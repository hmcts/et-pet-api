FactoryBot.define do
  factory :direct_uploaded_file do
    transient do
      file_to_attach { nil }
    end
    trait :example_pdf do
      filename { 'et1_first_last.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/pdf', filename: Rails.root.join("spec/fixtures/et1_first_last.pdf") } }
    end

    trait :plain_pdf do
      filename { 'plain.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/pdf', filename: Rails.root.join("spec/fixtures/plain.pdf") } }
    end

    trait :password_protected_pdf do
      filename { 'password_protected.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/pdf', filename: Rails.root.join("spec/fixtures/password_protected.pdf") } }
    end

    trait :plain_doc do
      filename { 'plain.doc' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/msword', filename: Rails.root.join("spec/fixtures/plain.doc") } }
    end

    trait :password_protected_doc do
      filename { 'password_protected.doc' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/msword', filename: Rails.root.join("spec/fixtures/password_protected.doc") } }
    end

    trait :plain_docx do
      filename { 'plain.docx' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        {
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          filename: Rails.root.join("spec/fixtures/plain.docx")
        }
      end
    end

    trait :password_protected_docx do
      filename { 'password_protected.docx' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        {
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          filename: Rails.root.join("spec/fixtures/password_protected.docx")
        }
      end
    end

    trait :plain_xls do
      filename { 'plain.xls' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/vnd.ms-excel', filename: Rails.root.join("spec/fixtures/plain.xls") } }
    end

    trait :password_protected_xls do
      filename { 'password_protected.xls' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/vnd.ms-excel', filename: Rails.root.join("spec/fixtures/password_protected.xls") } }
    end

    trait :plain_xlsx do
      filename { 'plain.xlsx' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        {
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          filename: Rails.root.join("spec/fixtures/plain.xlsx")
        }
      end
    end

    trait :password_protected_xlsx do
      filename { 'password_protected.xlsx' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        {
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          filename: Rails.root.join("spec/fixtures/password_protected.xlsx")
        }
      end
    end

    trait :plain_ppt do
      filename { 'plain.ppt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/vnd.ms-powerpoint', filename: Rails.root.join("spec/fixtures/plain.ppt") } }
    end

    trait :password_protected_ppt do
      filename { 'password_protected.ppt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/vnd.ms-powerpoint', filename: Rails.root.join("spec/fixtures/password_protected.ppt") } }
    end

    trait :plain_pptx do
      filename { 'plain.pptx' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        {
          content_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
          filename: Rails.root.join("spec/fixtures/plain.pptx")
        }
      end
    end

    trait :password_protected_pptx do
      filename { 'password_protected.pptx' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        {
          content_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
          filename: Rails.root.join("spec/fixtures/password_protected.pptx")
        }
      end
    end

    trait :plain_jpg do
      filename { 'plain.jpg' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'image/jpeg', filename: Rails.root.join("spec/fixtures/plain.jpg") } }
    end

    trait :example_claim_text do
      filename { 'et1_first_last.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/plain', filename: Rails.root.join("spec/fixtures/et1_first_last.txt") } }
    end

    trait :example_claim_rtf do
      filename { 'et1_attachment_first_last.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join("spec/fixtures/simple_user_with_rtf.rtf") } }
    end

    trait :example_claim_claimants_text do
      filename { 'et1a_first_last.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/plain', filename: Rails.root.join("spec/fixtures/et1a_first_last.txt") } }
    end

    trait :example_claim_claimants_csv do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join("spec/fixtures/simple_user_with_csv_group_claims.csv") } }
    end

    trait :example_claim_claimants_csv_with_spaces do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join("spec/fixtures/simple_user_with_csv_group_claims_with_spaces.csv") } }
    end

    trait :empty_csv do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join("spec/fixtures/empty.csv") } }
    end

    trait :example_claim_claimants_csv_missing_column do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join("spec/fixtures/simple_user_with_csv_group_claims_missing_column.csv") } }
    end

    trait :example_claim_claimants_csv_multiple_errors do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join("spec/fixtures/simple_user_with_csv_group_claims_multiple_errors.csv") } }
    end

    trait :example_claim_claimants_csv_bad_encoding do
      filename { 'et1a_first_last.csv' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'text/csv', filename: Rails.root.join("spec/fixtures/simple_user_with_csv_group_claims_bad_encoding.csv") } }
    end

    trait :example_response_text do
      filename { 'et3_atos_export.txt' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach do
        new_file = Tempfile.new(crlf_newline: true)
        original_filename = Rails.root.join("spec/fixtures/et3.txt")
        File.open(original_filename, 'r') do |f|
          f.each_line do |line|
            new_file.puts line
          end
        end
        new_file.close
        { content_type: 'text/plain', file: new_file, filename: original_filename }
      end
    end

    trait :example_response_rtf do
      filename { 'et3_atos_export.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join("spec/fixtures/simple_user_with_rtf.rtf") } }
    end

    trait :example_response_input_rtf do
      filename { 'additional_information.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join("spec/fixtures/example.rtf") } }
    end

    trait :example_response_wrong_input_rtf do
      filename { 'additional_information.rtf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/rtf', filename: Rails.root.join("spec/fixtures/simple_user_with_rtf.rtf") } }
    end

    # We do not have an example pdf yet - but the file contents does not really matter as nothing is reading it
    trait :example_response_pdf do
      filename { 'et3_atos_export.pdf' }
      checksum { 'ee2714b8b731a8c1e95dffaa33f89728' }
      file_to_attach { { content_type: 'application/pdf', filename: Rails.root.join("spec/fixtures/et1_first_last.pdf") } }
    end

    trait :example_data do
      example_pdf
    end

    trait :upload_to_blob do
      upload_method { :test }
    end

    trait :user_file_scope do
      file_scope { 'user' }
    end

    trait :system_file_scope do
      file_scope { 'system' }
    end

    after(:build) do |uploaded_file, evaluator|
      next if evaluator.file_to_attach.nil?

      begin
        file = evaluator.file_to_attach[:file]&.open || File.open(evaluator.file_to_attach[:filename], 'rb')
        uploaded_file.file.attach(io: file, filename: File.basename(evaluator.file_to_attach[:filename]), content_type: evaluator.file_to_attach[:content_type])
      end
    end
  end
end
