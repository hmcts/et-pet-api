# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Response, type: :model do
  subject(:response) { described_class.new }

  describe '#additional_information_key=' do
    context 'in amazon mode' do
      include_context 'with cloud provider switching', cloud_provider: :amazon
      let(:rtf_file_path) { Rails.root.join('spec', 'fixtures', 'example.rtf').to_s }
      # The json_response_data factory is being used just to generate a remote file - nothing else - saves duplicating that code
      let(:remote_key) do
        FactoryBot.build(:json_response_data, :with_rtf, rtf_file_path: rtf_file_path).additional_information_key
      end

      it 'imports a remote file into a new imported file named as the rtf file if it doesnt already exist' do
        # Act - Assign the remote url
        response.additional_information_key = remote_key

        # Assert - ensure an uploaded file has been built
        expect(response.uploaded_files.detect { |f| f.filename == 'additional_information.rtf' }.try(:file)).to be_a_stored_file_with_contents(File.read(rtf_file_path))
      end

      it 'does nothing if the new value is nil and the rtf file doesnt already exist' do
        # Act - Assign the remote url
        response.additional_information_key = nil

        # Assert - ensure an uploaded file has not been built
        expect(response.uploaded_files.length).to be 0
      end

      context 'with existing file' do
        subject(:response) { build(:response, :with_wrong_input_rtf_file) }

        it 'imports a remote file into an existing imported file if it already exist based on a set filename' do
          # Act - Assign the remote url
          response.additional_information_key = remote_key

          # Assert - ensure an uploaded file has been built
          expect(response.uploaded_files.detect { |f| f.filename == 'additional_information.rtf' }.try(:file)).to be_a_stored_file_with_contents(File.read(rtf_file_path))
        end

        it 'removes an imported file if it already exist based on a set filename and the new value is nil' do
          # Act - Assign the remote url
          response.additional_information_key = nil

          # Assert - ensure an uploaded file has been removed
          expect(response.uploaded_files.length).to be 0
        end
      end
    end
    context 'in azure mode' do
      include_context 'with cloud provider switching', cloud_provider: :azure
      let(:rtf_file_path) { Rails.root.join('spec', 'fixtures', 'example.rtf').to_s }
      # The json_response_data factory is being used just to generate a remote file - nothing else - saves duplicating that code
      let(:remote_key) do
        FactoryBot.build(:json_response_data, :with_rtf, rtf_file_path: rtf_file_path).additional_information_key
      end

      it 'imports a remote file into a new imported file named as the rtf file if it doesnt already exist' do
        # Act - Assign the remote url
        response.additional_information_key = remote_key

        # Assert - ensure an uploaded file has been built
        expect(response.uploaded_files.detect { |f| f.filename == 'additional_information.rtf' }.try(:file)).to be_a_stored_file_with_contents(File.read(rtf_file_path))
      end

      it 'does nothing if the new value is nil and the rtf file doesnt already exist' do
        # Act - Assign the remote url
        response.additional_information_key = nil

        # Assert - ensure an uploaded file has not been built
        expect(response.uploaded_files.length).to be 0
      end

      context 'with existing file' do
        subject(:response) { build(:response, :with_wrong_input_rtf_file) }

        it 'imports a remote file into an existing imported file if it already exist based on a set filename' do
          # Act - Assign the remote url
          response.additional_information_key = remote_key

          # Assert - ensure an uploaded file has been built
          expect(response.uploaded_files.detect { |f| f.filename == 'additional_information.rtf' }.try(:file)).to be_a_stored_file_with_contents(File.read(rtf_file_path))
        end

        it 'removes an imported file if it already exist based on a set filename and the new value is nil' do
          # Act - Assign the remote url
          response.additional_information_key = nil

          # Assert - ensure an uploaded file has been removed
          expect(response.uploaded_files.length).to be 0
        end
      end
    end
  end

  describe '#additional_information_rtf_file?' do
    context 'with an attached file' do
      subject(:response) { build(:response, :example_data, :with_input_rtf_file) }

      it 'returns true' do
        expect(response.additional_information_rtf_file?).to be true
      end
    end

    context 'with no attached file' do
      subject(:response) { build(:response, :example_data) }

      it 'returns false' do
        expect(response.additional_information_rtf_file?).to be false
      end
    end
  end

  describe '#office' do
    subject(:response) { build(:response) }

    it 'returns the correct office with the code matching the first 2 chars of the reference' do
      expect(response.office).to be_a(Office).and(have_attributes(code: 22))
    end
  end
end
