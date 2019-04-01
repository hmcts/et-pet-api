require 'rails_helper'

RSpec.describe BuildSecondaryClaimantsCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:claimant1) { build(:json_claimant_data, :mr_first_last).as_json.stringify_keys }
  let(:claimant2) { build(:json_claimant_data, :tamara_swift).as_json.stringify_keys }
  let(:data) { [claimant1, claimant2] }
  let(:root_object) { Claim.new }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.secondary_claimants).to contain_exactly(an_object_having_attributes(claimant1.except('address_attributes', 'date_of_birth')),
        an_object_having_attributes(claimant2.except('address_attributes', 'date_of_birth')))
    end
  end
end
