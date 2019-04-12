require 'rails_helper'

RSpec.describe CreateDiversityResponseCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_build_diversity_response_data, :full).to_h.stringify_keys }
  let(:root_object) { build(:diversity_response) }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.attributes.to_h).to include data
    end

    it 'saves the root object with save!' do
      # Arrange
      root_object = build(:diversity_response)
      allow(root_object).to receive(:save!)

      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to have_received(:save!)
    end

    it 'publishes the DiversityResponseCreated event' do
      # Arrange - Spy on the event service
      allow(Rails.application.event_service).to receive(:publish)

      # Act
      command.apply(root_object)

      # Assert
      expect(Rails.application.event_service).to have_received(:publish).with('DiversityResponseCreated', root_object)
    end
  end
end
