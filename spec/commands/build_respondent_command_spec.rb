require 'rails_helper'

RSpec.describe BuildRespondentCommand do
  let(:uuid) { SecureRandom.uuid }
  let(:data) do
    {
      name: 'Fred Bloggs'
    }
  end
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:root_object) { Response.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to have_attributes respondent: an_object_having_attributes(name: 'Fred Bloggs')
    end
  end
end
