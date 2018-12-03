require 'rails_helper'

RSpec.describe BuildDiversityResponseCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_build_diversity_response_data, :full).to_h.stringify_keys }
  let(:root_object) { DiversityResponse.new }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.attributes.to_h).to include data
    end
  end
end
