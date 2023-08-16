require 'rails_helper'

RSpec.describe BuildSecondaryClaimantsCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:first_claimant) { build(:json_claimant_data, :mr_first_last).as_json.stringify_keys }
  let(:second_claimant) { build(:json_claimant_data, :tamara_swift).as_json.stringify_keys }
  let(:data) { [first_claimant, second_claimant] }
  let(:root_object) { Claim.new }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.secondary_claimants).to contain_exactly(an_object_having_attributes(first_claimant.except('address_attributes', 'date_of_birth')),
                                                                 an_object_having_attributes(second_claimant.except('address_attributes', 'date_of_birth')))
    end
  end
end
