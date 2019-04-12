require 'rails_helper'

RSpec.describe ValidateClaimantsFileCommand do
  subject(:command) { described_class.new(**data.as_json.symbolize_keys) }

  let(:uuid) { SecureRandom.uuid }

  include_context 'with cloud provider switching', cloud_provider: :local
  include_context 'with disabled event handlers'

  describe '#valid?' do
    context 'with valid data' do
      let(:data) { FactoryBot.build(:json_validate_claimants_file_command, :valid) }

      it 'is valid' do
        # Act
        expect(command.valid?).to be true
      end
    end

    context 'with date of birth that is invalid in one row and a title that is not in the list in another' do
      let(:data) { FactoryBot.build(:json_validate_claimants_file_command, :invalid) }

      it 'is invalid' do
        # Act
        expect(command.valid?).to be false
      end

      it 'contains the correct errors for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details).to include \
          'data_from_key[0].date_of_birth': a_collection_containing_exactly(
            a_hash_including(error: :invalid, uuid: data.uuid, command: data.command)
          ),
          'data_from_key[1].title': a_collection_containing_exactly(
            a_hash_including(error: :inclusion, uuid: data.uuid, command: data.command)
          )
      end

      it 'contains the correct error messages for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.messages).to include \
          'data_from_key[0].date_of_birth': a_collection_containing_exactly('is invalid'),
          'data_from_key[1].title': a_collection_containing_exactly('is not included in the list')
      end
    end

    context 'with a file containing lots of encoding issues' do
      let(:data) { FactoryBot.build(:json_validate_claimants_file_command, :invalid_encoding) }

      it 'is valid' do
        # Act
        expect(command.valid?).to be true
      end
    end

    context 'with a file containing a missing column' do
      let(:data) { FactoryBot.build(:json_validate_claimants_file_command, :missing_column) }


      it 'is invalid' do
        # Act
        expect(command.valid?).to be false
      end

      it 'contains the correct errors for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details).to include \
          'base': a_collection_containing_exactly(
          a_hash_including(error: :invalid_columns, uuid: data.uuid, command: data.command)
        )
      end

      it 'contains the correct error messages for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.messages).to include \
          'base': a_collection_containing_exactly('file does not contain the correct columns')
      end
    end

    context 'with an empty file' do
      let(:data) { FactoryBot.build(:json_validate_claimants_file_command, :empty) }


      it 'is invalid' do
        # Act
        expect(command.valid?).to be false
      end

      it 'contains the correct errors for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details).to include \
          'base': a_collection_containing_exactly(
          a_hash_including(error: :empty_file, uuid: data.uuid, command: data.command)
        )
      end

      it 'contains the correct error messages for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.messages).to include \
          'base': a_collection_containing_exactly('file is empty')
      end
    end

    context 'with an missing file' do
      let(:data) { FactoryBot.build(:json_validate_claimants_file_command, :missing) }


      it 'is invalid' do
        # Act
        expect(command.valid?).to be false
      end

      it 'contains the correct errors for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details).to include \
          'base': a_collection_containing_exactly(
          a_hash_including(error: :missing_file, uuid: data.uuid, command: data.command)
        )
      end

      it 'contains the correct error messages for this example' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.messages).to include \
          'base': a_collection_containing_exactly('file is missing')
      end

    end
  end
end
