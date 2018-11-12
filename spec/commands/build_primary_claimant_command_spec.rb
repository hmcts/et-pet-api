require 'rails_helper'

RSpec.describe BuildPrimaryClaimantCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_claimant_data, :mr_first_last).as_json.stringify_keys }
  let(:root_object) { Claim.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.primary_claimant).to have_attributes(data.except('address_attributes', 'date_of_birth')).
        and(have_attributes(date_of_birth: an_instance_of(Date))).
        and(have_attributes(address: an_object_having_attributes(data['address_attributes'])))

    end
  end
end
