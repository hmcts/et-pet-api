require 'rails_helper'

RSpec.describe ExportedFile, type: :model do
  subject(:exported_file) { described_class.new }

  let(:fixture_file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/et1_first_last.pdf"), 'application/pdf') }

  describe '#file=' do
    it 'persists it in memory as an activestorage attachment' do
      exported_file.file = fixture_file

      expect(exported_file.file).to be_a_stored_file
    end
  end

  describe '#url' do
    context 'with azure cloud provider' do
      include_context 'with local storage'
      it 'returns an azurite test server url as we are in test mode' do
        exported_file.file = fixture_file

        expect(URI.parse(exported_file.url).path).to start_with('/rails/active_storage/disk')
      end
    end
  end

  describe '#download_blob_to' do
    subject(:exported_file) { create(:exported_file, file: fixture_file) }

    it 'downloads a file to the specified location' do
      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'my_file.pdf')
        # Act - download the blob
        exported_file.download_blob_to filename

        # Assert - make sure its there
        expect(File.exist?(filename)).to be true
      end
    end

    it 'downloads the correct file to the specified location' do
      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'my_file.pdf')
        # Act - download the blob
        exported_file.download_blob_to filename

        # Assert - make sure its there
        expect(filename).to be_a_file_copy_of fixture_file.path
      end
    end
  end
end
