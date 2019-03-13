require 'rails_helper'

RSpec.describe UploadedFileImportService do
  subject(:service) { described_class }

  let(:uploaded_file) { build(:uploaded_file, filename: 'anything') }
  let(:fixture_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf') }

  describe '#import_file_url' do
    shared_examples 'import_file_url examples' do
      it 'allows nil as meaning no import from url required' do
        # Arrange and Act - set to nil
        service.import_file_url(nil, into: uploaded_file)

        # Assert
        expect(uploaded_file.file.attachment).to be_nil
      end

      it 'imports from a remote url' do
        # Arrange - Store a file remotely
        remote_file = create(:uploaded_file, :example_pdf)

        # Act - Import it
        service.import_file_url(remote_file.file.service_url, into: uploaded_file)

        # Assert - Make sure the file is imported
        Dir.mktmpdir do |dir|
          filename = File.join(dir, 'my_file.pdf')
          # Act - download the blob
          uploaded_file.download_blob_to filename

          # Assert - make sure its a copy of the source
          expect(filename).to be_a_file_copy_of(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
        end
      end
    end

    # @TODO RST-1676 - The amazon block can be removed
    context 'when in amazon mode' do
      include_context 'with cloud provider switching', cloud_provider: :amazon
      include_examples('import_file_url examples')
    end

    context 'when in azure mode' do
      include_context 'with cloud provider switching', cloud_provider: :azure
      include_examples('import_file_url examples')
    end
  end

  describe '#import_from_key' do
    shared_examples 'import_from_key examples' do
      it 'imports from a key from the direct upload container' do
        # Arrange - Store a file in the direct upload container
        remote_file = create(:uploaded_file, :example_pdf, :direct_upload)

        # Act
        service.import_from_key(remote_file.file.blob.key, into: uploaded_file)

        # Assert - Make sure the file is imported
        Dir.mktmpdir do |dir|
          filename = File.join(dir, 'my_file.pdf')
          # Act - download the blob
          uploaded_file.download_blob_to filename

          # Assert - make sure its a copy of the source
          expect(filename).to be_a_file_copy_of(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
        end
      end

      it 'removes the original when done' do
        # Arrange - Store a file in the direct upload container
        remote_file = create(:uploaded_file, :example_pdf, :direct_upload)

        # Act
        service.import_from_key(remote_file.file.blob.key, into: uploaded_file)

        # Assert - Make sure original has gone
        expect(remote_file.file.blob.service.exist?(remote_file.file.blob.key)).to be false
      end
    end

    context 'when in amazon mode' do
      include_context 'with cloud provider switching', cloud_provider: :amazon
      include_examples 'import_from_key examples'
    end

    context 'when in azure mode' do
      include_context 'with cloud provider switching', cloud_provider: :azure
      include_examples 'import_from_key examples'
    end
  end
end
