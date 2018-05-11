require 'rails_helper'

RSpec.describe EventService do
  subject(:service) { described_class }

  describe '.publish' do
    let(:handle_spy) { instance_spy(Proc) }
    let(:dummy_event_handler) do
      local_handle_spy = handle_spy
      Class.new do

        define_method :handle do | *args |
          local_handle_spy.call(*args)
        end
      end
    end

    before do
      service.subscribe('my_special_event', dummy_event_handler)
    end

    after do
      service.unsubscribe('my_special_event', dummy_event_handler)
    end

    it 'publishes and the dummy event handler receives it' do

      # Act - Publish an event
      service.publish('my_special_event', 'arg1', 'arg2')

      # Assert - Ensure the dummy event handler got it
      expect(handle_spy).to have_received(:call).with('arg1', 'arg2')
    end
  end

  describe '.ignoring_events' do
    let(:handle_spy) { instance_spy(Proc) }
    let(:dummy_event_handler) do
      local_handle_spy = handle_spy
      Class.new do

        define_method :handle do | *args |
          local_handle_spy.call(*args)
        end
      end
    end

    before do
      service.subscribe('my_special_event', dummy_event_handler)
    end

    after do
      service.unsubscribe('my_special_event', dummy_event_handler)
    end

    it 'does not publish the event' do
      # Act - attempt to publish something inside the ignoring_events block
      service.ignoring_events do
        service.publish('my_special_event', 'arg1', 'arg2')
      end

      # Assert - Ensure the dummy event handler did not receive anything
      expect(handle_spy).not_to have_received(:call)
    end
  end
end
