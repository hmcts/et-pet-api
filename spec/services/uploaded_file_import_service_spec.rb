require 'rails_helper'

RSpec.describe UploadedFileImportService do
  subject(:service) { described_class }

  let(:uploaded_file) { build(:uploaded_file, filename: 'anything') }
  let(:fixture_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf') }
  before do
    Capybara.current_driver = :selenium
    Capybara.current_session
    capybara_url = URI.parse(Capybara.current_session.server_url)
    ActiveStorage::Current.url_options = { host: capybara_url.host, port: capybara_url.port }
  end

  after do
    Capybara.use_default_driver
  end

  describe '#import_file_url' do
    context 'when in azure mode' do
      include_context 'with cloud provider switching', cloud_provider: :test
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
        service.import_file_url(remote_file.file.url, into: uploaded_file)

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
  end

  describe '#import_from_key' do
    include_context 'with cloud provider switching', cloud_provider: :test
    it 'imports from a key from the direct upload container' do
      # Arrange - Store a file in the direct upload container
      remote_file = create(:direct_uploaded_file, :example_pdf)

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
      remote_file = create(:direct_uploaded_file, :example_pdf)

      # Act
      service.import_from_key(remote_file.file.blob.key, into: uploaded_file)

      # Assert - Make sure original has gone
      expect(DirectUploadedFile.find_by_key(remote_file.file.blob.key)).to be nil
    end
  end
end
