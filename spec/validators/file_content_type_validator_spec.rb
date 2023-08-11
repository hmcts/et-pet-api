# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileContentTypeValidator do
  describe '#valid?' do
    class ExampleClass < ActiveRecord::Base
      include ScannedContentType
      establish_connection adapter: :nulldb,
                           schema: 'config/nulldb_schema.rb'
      has_one_attached :file
      scan_content_type_for :file
      validates :file, file_content_type: true
    end

    subject(:model) { ExampleClass.new(file: example_file) }

    context 'where the file contents matches the extension' do
      let(:example_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/simple_user_with_rtf.rtf'), 'application/rtf', false) }

      before { subject.valid? }

      it 'allows the file' do
        expect(subject.errors).to be_empty
      end
    end

    context 'where the file contents done match the extension' do
      let(:example_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/invalid_content_type.rtf'), 'application/rtf', false) }

      before { subject.valid? }

      it 'allows the file' do
        expect(subject.errors.where(:file, :mismatching_file_content_type)).to be_present
      end
    end

  end
end
