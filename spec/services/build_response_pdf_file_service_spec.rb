require 'rails_helper'

RSpec.describe BuildResponsePdfFileService do
  subject(:builder) { described_class }

  let(:errors) { [] }

  describe '#call' do
    shared_examples 'for any response variation' do
      it 'stores an ET3 pdf file with the correct filename' do
        # Act
        builder.call(response)

        # Assert
        expect(response.uploaded_files).to include an_object_having_attributes filename: 'et3_atos_export.pdf',
                                                                               file: be_a_stored_file

      end

      it 'stores an ET3 pdf file from the english v1 template with the correct contents' do
        # Act
        builder.call(response)
        response.save!

        # Assert
        uploaded_file = response.uploaded_files.where(filename: 'et3_atos_export.pdf').first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, 'et3_atos_export.pdf')
          uploaded_file.download_blob_to(full_path)
          File.open full_path do |file|
            et3_file = EtApi::Test::FileObjects::Et3PdfFile.new(file, template: 'et3-v1-en', lookup_root: 'response_pdf_fields')
            expect(et3_file).to have_correct_contents_from_db_for(errors: errors, response: response), -> { errors.join("\n") }
          end
        end
      end
    end

    context 'with a representative' do
      let(:response) { build(:response, :example_data, :with_representative) }

      include_examples 'for any response variation'
    end

    context 'without a representative' do
      let(:response) { build(:response, :example_data, :without_representative) }

      include_examples 'for any response variation'
    end

    context 'with an attached rtf file' do
      let(:response) { build(:response, :example_data, :with_input_rtf_file) }

      include_examples 'for any response variation'
    end

    context 'with a pre allocated s3 key to allow for providing the url before the file is uploaded' do
      let(:response) { build(:response, :example_data) }

      context 'with data created in db' do
        it 'is available at the location provided' do
          # Arrange - Create a pre allocation
          response.save
          blob = ActiveStorage::Blob.new(filename: 'et3_atos_export.pdf', byte_size: 0, checksum: 0)
          original_url = blob.service_url(expires_in: 1.hour)
          PreAllocatedFileKey.create(allocated_to: response, key: blob.key, filename: 'et3_atos_export.pdf')

          # Act
          builder.call(response)
          response.save!

          expect(HTTParty.get(original_url).code).to be 200
        end
      end
    end

    context 'using an alternative pdf template' do
      let(:response) { build(:response, :example_data, :with_representative) }

      it 'stores an ET3 pdf file from the welsh v1 template with the correct contents' do
        # Act
        builder.call(response, template_reference: 'et3-v1-cy')
        response.save!

        # Assert
        uploaded_file = response.uploaded_files.where(filename: 'et3_atos_export.pdf').first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, 'et3_atos_export.pdf')
          uploaded_file.download_blob_to(full_path)
          File.open full_path do |file|
            et3_file = EtApi::Test::FileObjects::Et3PdfFile.new(file, template: 'et3-v1-cy', lookup_root: 'response_pdf_fields')
            expect(et3_file).to have_correct_contents_from_db_for(errors: errors, response: response), -> { errors.join("\n") }
          end
        end
      end
    end
  end
end
