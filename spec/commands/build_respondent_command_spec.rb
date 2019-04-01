require 'rails_helper'

RSpec.describe BuildRespondentCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:root_object) { Response.new }

  include_context 'with disabled event handlers'

  describe '#apply' do
    context 'with full data set' do
      let(:data) { build(:json_respondent_data, :full).as_json }

      it 'applies the data to the root object' do
        # Act
        command.apply(root_object)

        # Assert
        expect(root_object.respondent).to have_attributes(data.except(:work_address_attributes, :address_attributes)).
          and(have_attributes(address: an_object_having_attributes(data[:address_attributes]))).
          and(have_attributes(work_address: an_object_having_attributes(data[:work_address_attributes])))
      end
    end

    context 'with partial data set' do
      let(:data) { build(:json_respondent_data, :minimal).as_json.except(:work_address_attributes, :address_attributes) }

      it 'applies the data to the root object' do
        # Act
        command.apply(root_object)

        # Assert
        expect(root_object.respondent).to have_attributes(data.except(:work_address_attributes, :address_attributes)).
          and(have_attributes(address: nil)).
          and(have_attributes(work_address: nil))
      end
    end
  end

  describe '#valid?' do
    describe 'address attributes' do
      context 'with valid address_attributes' do
        let(:data) { build(:json_respondent_data, :full).as_json }

        it 'contains no error key in the address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:address_attributes]).to be_empty
        end
      end

      context 'with missing address_attributes' do
        let(:data) { build(:json_respondent_data, :full).as_json.except(:address_attributes) }

        it 'contains the correct error key in the address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:address_attributes]).to include(error: :blank)
        end
      end

      context 'with invalid address_attributes' do
        let(:data) { build(:json_respondent_data, :full, :invalid_address_keys).as_json }

        it 'contains the correct error key in the address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:address_attributes]).to include(error: :invalid_address)
        end
      end

      context 'with invalid address_attributes - nil value' do
        let(:data) { build(:json_respondent_data, :full).as_json.merge(address_attributes: nil) }

        it 'contains the correct error key in the address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:address_attributes]).to include(error: :invalid_address)
        end
      end

      context 'with empty address_attributes' do
        let(:data) { build(:json_respondent_data, :full).as_json.merge(address_attributes: {}) }

        it 'contains no error in the work_address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:address_attributes]).to include(error: :invalid_address)
        end
      end
    end

    describe 'work_address attributes' do
      context 'with valid address_attributes' do
        let(:data) { build(:json_respondent_data, :full).as_json }

        it 'contains no error in the work_address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:work_address_attributes]).to be_empty
        end
      end

      context 'with missing work_address_attributes' do
        let(:data) { build(:json_respondent_data, :full).as_json.except(:address_attributes) }

        it 'contains no error in the work_address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:work_address_attributes]).to be_empty
        end
      end

      context 'with empty work_address_attributes' do
        let(:data) { build(:json_respondent_data, :full).as_json.merge(work_address_attributes: {}) }

        it 'contains no error in the work_address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:work_address_attributes]).to be_empty
        end
      end

      context 'with invalid work_address_attributes' do
        let(:data) { build(:json_respondent_data, :full, :invalid_work_address_keys).as_json }

        it 'contains the correct error key in the work_address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:work_address_attributes]).to include(error: :invalid_address)
        end
      end

      context 'with invalid work_address_attributes - nil value' do
        let(:data) { build(:json_respondent_data, :full).as_json.merge(work_address_attributes: nil) }

        it 'contains the correct error key in the work_address_attributes attribute' do
          # Act
          command.valid?

          # Assert
          expect(command.errors.details[:work_address_attributes]).to include(error: :invalid_address)
        end
      end
    end
  end

end
