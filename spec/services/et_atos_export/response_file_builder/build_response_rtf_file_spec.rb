require 'rails_helper'

RSpec.describe EtAtosExport::ResponseFileBuilder::BuildResponseRtfFile do
  subject(:builder) { described_class }

  let(:errors) { [] }

  describe '#call' do
    let(:response) { create(:response, :with_input_rtf_file) }

    it 'stores an ET3 response file with the correct filename' do
      # Act
      builder.call(response)

      # Assert
      expect(response.uploaded_files.filter(&:system_file_scope?)).to include an_object_having_attributes filename: 'et3_atos_export_additional_information.pdf',
                                                                             file: be_a_stored_file
    end

    it 'stores an ET3 response file which is a copy of the original' do
      # Act
      builder.call(response)
      response.save!

      # Assert
      uploaded_file = response.uploaded_files.system_file_scope.where(filename: 'et3_atos_export_additional_information.pdf').first
      Dir.mktmpdir do |dir|
        original_path = File.join(dir, 'original.pdf')
        original_file = response.uploaded_files.system_file_scope.detect { |f| f.filename == 'additional_information.pdf' }

        full_path = File.join(dir, 'et3_atos_export_additional_information.pdf')
        uploaded_file.download_blob_to(full_path)
        original_file.download_blob_to(original_path)
        File.open full_path do |file|
          expect(file).to be_a_file_copy_of(original_path)
        end
      end
    end

    context 'with no input additional_information file' do
      let(:response) { build(:response) }

      it 'succeeds but does nothing if no input additional_information file' do
        # Act
        builder.call(response)

        # Assert
        expect(response.uploaded_files).to be_empty
      end
    end

  end
end
