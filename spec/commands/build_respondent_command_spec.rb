require 'rails_helper'

RSpec.describe BuildRespondentCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:root_object) { Response.new }

  describe '#apply' do
    context 'full data set' do
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
    context 'partial data set' do
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
end
