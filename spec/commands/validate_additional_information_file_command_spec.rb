require 'rails_helper'

RSpec.describe ValidateAdditionalInformationFileCommand do
  subject(:command) { described_class.new(**data.as_json.symbolize_keys) }

  include_context 'with local storage'
  include_context 'with disabled event handlers'

  describe '#valid?' do
    context 'with valid data' do
      let(:data) { build(:json_validate_additional_information_file_command, :valid) }

      it 'is valid' do
        expect(command.valid?).to be true
      end
    end

    context 'with a password protected file' do
      let(:data) { build(:json_validate_additional_information_file_command, :password_protected) }

      it 'is invalid' do
        expect(command.valid?).to be false
      end

      it 'contains the correct errors for this example' do
        command.valid?

        expect(command.errors.details.to_hash).to include \
          data_from_key: a_collection_containing_exactly(
            a_hash_including(error: :password_protected, uuid: data.uuid, command: data.command)
          )
      end

      it 'contains the correct error messages for this example' do
        command.valid?

        expect(command.errors.messages.to_hash).to include \
          data_from_key: a_collection_containing_exactly("This file is password protected. Upload a file that isn’t password protected.")
      end
    end

    context 'with a missing file' do
      let(:data) { build(:json_validate_additional_information_file_command, :missing) }

      it 'is invalid' do
        expect(command.valid?).to be false
      end

      it 'contains the correct errors for this example' do
        command.valid?

        expect(command.errors.details.to_hash).to include \
          base: a_collection_containing_exactly(
            a_hash_including(error: :missing_file, uuid: data.uuid, command: data.command)
          )
      end

      it 'contains the correct error messages for this example' do
        command.valid?

        expect(command.errors.messages.to_hash).to include \
          base: a_collection_containing_exactly('file is missing')
      end
    end
  end
end
