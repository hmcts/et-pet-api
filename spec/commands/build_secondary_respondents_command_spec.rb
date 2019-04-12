require 'rails_helper'

RSpec.describe BuildSecondaryRespondentsCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:respondent1) { build(:json_respondent_data, :full).as_json.stringify_keys }
  let(:respondent2) { build(:json_respondent_data, :full, contact: 'Respondent Two').as_json.stringify_keys }
  let(:data) { [respondent1, respondent2] }
  let(:root_object) { Claim.new }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.secondary_respondents).to contain_exactly(an_object_having_attributes(respondent1.except('address_attributes', 'work_address_attributes')),
        an_object_having_attributes(respondent2.except('address_attributes', 'work_address_attributes')))
    end
  end
end
