require 'rails_helper'

RSpec.describe BuildFeedbackCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_feedback_data).to_h.stringify_keys }
  let(:root_object) { {} }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to include data
    end

    it 'publishes the FeedbackCreated event' do
      # Arrange - Spy on the event service
      allow(Rails.application.event_service).to receive(:publish)

      # Act
      command.apply(root_object)

      # Assert
      expect(Rails.application.event_service).to have_received(:publish).with('FeedbackCreated', root_object)
    end
  end
end
