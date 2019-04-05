require 'rails_helper'

RSpec.describe BuildClaimPdfFileService do
  subject(:builder) { described_class }

  let(:errors) { [] }

  describe '#call' do
    let(:correct_filename) do
      scrubber = ->(text) { text.gsub(/\s/, '_').gsub(/\W/, '').downcase }
      "et1_#{scrubber.call claim.primary_claimant.first_name}_#{scrubber.call claim.primary_claimant.last_name}.pdf"
    end

    include_context "with disabled event handlers"

    shared_examples 'for any claim variation' do
      it 'stores an ET1 pdf file with the correct filename' do
        # Act
        builder.call(claim)

        # Assert
        expect(claim.uploaded_files).to include an_object_having_attributes filename: correct_filename,
                                                                            file: be_a_stored_file

      end

      it 'stores an ET1 pdf file from the english v1 template with the correct contents' do
        # Act
        builder.call(claim)
        claim.save!

        # Assert
        uploaded_file = claim.uploaded_files.where(filename: correct_filename).first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, correct_filename)
          uploaded_file.download_blob_to(full_path)
          File.open full_path do |file|
            et1_file = EtApi::Test::FileObjects::Et1PdfFile.new(file, template: 'et1-v1-en', lookup_root: 'claim_pdf_fields')
            expect(et1_file).to have_correct_contents_from_db_for(errors: errors, claim: claim), -> { errors.join("\n") }
          end
        end
      end
    end

    context 'with a representative' do
      let(:claim) { build(:claim, :example_data) }

      include_examples 'for any claim variation'
    end

    context 'without a representative' do
      let(:claim) { build(:claim, :example_data, :without_representative) }

      include_examples 'for any claim variation'
    end

    context 'with an attached rtf file' do
      let(:claim) { build(:claim, :example_data, :with_rtf_file) }

      include_examples 'for any claim variation'
    end

    context 'with a pre allocated s3 key to allow for providing the url before the file is uploaded' do
      let(:claim) { build(:claim, :example_data) }

      context 'with data created in db' do
        it 'is available at the location provided' do
          # Arrange - Create a pre allocation
          claim.save
          blob = ActiveStorage::Blob.new(filename: correct_filename, byte_size: 0, checksum: 0)
          original_url = blob.service_url(expires_in: 1.hour)
          PreAllocatedFileKey.create(allocated_to: claim, key: blob.key, filename: correct_filename)

          # Act
          builder.call(claim)
          claim.save!

          expect(HTTParty.get(original_url).code).to be 200
        end
      end
    end

    context 'when using an alternative pdf template' do
      let(:claim) { build(:claim, :example_data) }

      it 'stores an ET1 pdf file from the welsh v1 template with the correct contents' do
        # Act
        builder.call(claim, template_reference: 'et1-v1-cy')
        claim.save!

        # Assert
        uploaded_file = claim.uploaded_files.where(filename: correct_filename).first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, correct_filename)
          uploaded_file.download_blob_to(full_path)
          File.open full_path do |file|
            et1_file = EtApi::Test::FileObjects::Et1PdfFile.new(file, template: 'et1-v1-cy', lookup_root: 'claim_pdf_fields')
            expect(et1_file).to have_correct_contents_from_db_for(errors: errors, claim: claim), -> { errors.join("\n") }
          end
        end
      end
    end
  end
end
