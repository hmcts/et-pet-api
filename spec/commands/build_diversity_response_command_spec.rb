require 'rails_helper'

RSpec.describe BuildDiversityResponseCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) do
    {
      claim_type: 'Discrimination'
    }
  end
  let(:root_object) { DiversityResponse.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.claim_type).to eql 'Discrimination'
    end
  end
end
