require 'rails_helper'

RSpec.describe CommandService do
  subject(:service) { described_class }

  describe '.dispatch' do
    context 'with a valid command' do
      let(:command_instance) { instance_spy('DummyCommand').tap { |instance| allow(instance).to receive(:apply).and_return instance } }
      let(:command_class) { class_spy('DummyCommand', new: command_instance).as_stubbed_const }
      let(:uuid) { SecureRandom.uuid }
      let(:data) { { anything: :goes } }
      let(:root_object) { Object.new }

      before do
        command_class
      end

      it 'creates a new instance of the command' do
        # Act - call dispatch
        service.dispatch command: 'Dummy',
                         uuid: uuid,
                         data: data,
                         root_object: root_object

        # Assert - Make sure the command class received new with the correct params
        expect(command_class).to have_received(:new).with(uuid: uuid, data: data)
      end

      it 'calls apply on the command with the root object passed in' do
        # Act - call dispatch
        service.dispatch command: 'Dummy',
                         uuid: uuid,
                         data: data,
                         root_object: root_object

        # Assert - Make sure the command instance receives apply with the root object passed
        expect(command_instance).to have_received(:apply).with(root_object)
      end

      it 'returns the command' do
        # Act - call dispatch
        result = service.dispatch command: 'Dummy',
                                  uuid: uuid,
                                  data: data,
                                  root_object: root_object

        # Assert - Make sure the command instance is returned
        expect(result).to be command_instance
      end
    end
  end
end
