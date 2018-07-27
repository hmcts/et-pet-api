require 'rails_helper'

RSpec.describe BuildRepresentativeCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) do
    {
      name: 'Fred Bloggs'
    }
  end
  let(:root_object) { Response.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to have_attributes representative: an_object_having_attributes(name: 'Fred Bloggs')
    end
  end
end
