require 'rails_helper'

RSpec.describe UploadedFile, type: :model do
  subject(:uploaded_file) { described_class.new }

  let(:fixture_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf') }

  describe '#file=' do
    it 'persists it in memory as an activestorage attachment' do
      uploaded_file.file = fixture_file

      expect(uploaded_file.file).to be_a_stored_file
    end
  end

  describe '#url' do
    it 'returns a local url as we are in test mode' do
      uploaded_file.file = fixture_file

      expect(uploaded_file.url).to match(/\Ahttp:\/\/example.com\/rails\/active_storage\/disk\/.*et1_first_last\.pdf\z/)
    end
  end
end
