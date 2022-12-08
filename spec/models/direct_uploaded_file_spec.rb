require 'rails_helper'

RSpec.describe DirectUploadedFile, type: :model do
  describe 'validation' do
    it 'rejects a file if the content type does not seem to match the file extension' do
      example_file_path = Rails.root.join('spec/fixtures/invalid_content_type.rtf')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'application/rtf', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      uploaded_file.valid?
      expect(uploaded_file.errors.where(:file, :mismatching_file_content_type)).to be_present
      expect(uploaded_file.errors[:file]).to include "The contents of the file does not appear to be valid for the file extension 'rtf'"
    end

    it 'accepts a file if the content type does match the file extension' do
      example_file_path = Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'application/rtf', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      uploaded_file.valid?
      expect(uploaded_file.errors.where(:file, :mismatching_file_content_type)).to be_empty
    end

    it 'uploads to the direct upload store on save' do
      example_file_path = Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'application/rtf', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      uploaded_file.save!
      expect(uploaded_file.file.service_name).to end_with('direct_upload')
    end
  end

  describe '#key' do
    it 'returns a string' do
      example_file_path = Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'application/rtf', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      expect(uploaded_file.key).to be_an_instance_of(String)
    end
  end

  describe '#content_type' do
    it 'is application/rtf for an rtf file' do
      example_file_path = Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'application/rtf', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      expect(uploaded_file.content_type).to eql 'application/rtf'
    end

    it 'is text/csv for a csv file' do
      example_file_path = Rails.root.join('spec/fixtures/simple_user_with_csv_group_claims.csv')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'text/csv', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      expect(uploaded_file.content_type).to eql 'text/csv'
    end
  end

  describe '#filename' do
    it 'is the same as the provided filename' do
      example_file_path = Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf')
      example_file = Rack::Test::UploadedFile.new(example_file_path, 'application/rtf', false)
      uploaded_file = described_class.new(file: example_file, filename: File.basename(example_file_path))
      expect(uploaded_file.filename).to eql 'simple_user_with_rtf.rtf'
    end
  end
end
