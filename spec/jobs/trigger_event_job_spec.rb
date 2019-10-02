require 'rails_helper'
RSpec.describe TriggerEventJob do
  subject(:worker) { described_class.new event_service: mock_event_service }
  let(:mock_event_service) { instance_spy(EventService) }

  describe "#perform" do
    it 'delegates the call to the event service publish' do
      # Act
      worker.perform('TestEvent', { 'dummy' => 'data'})

      # Assert
      expect(mock_event_service).to have_received(:publish).with('TestEvent', { 'dummy' => 'data' })
    end
  end
end
