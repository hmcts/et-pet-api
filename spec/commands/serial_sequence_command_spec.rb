require 'rails_helper'

RSpec.describe SerialSequenceCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data, command_service: command_service) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) do
    [
      {
        command: 'Dummy1',
        uuid: SecureRandom.uuid,
        data: { doesnt: :matter }
      }.with_indifferent_access,
      {
        command: 'Dummy2',
        uuid: SecureRandom.uuid,
        data: { doesnt: :matter }
      }.with_indifferent_access
    ]
  end
  let(:root_object) { Object.new }

  describe '#apply' do
    let(:command_service) { class_spy(CommandService, dispatch: positive_command_instance) }
    let(:positive_command_instance) { instance_spy(CommandService::CommandResponse, valid?: true, command: nil, meta: { reference: '123456' }) }

    it 'calls dispatch on the command service for each command in the data' do
      # Act - Call the method
      #
      command.apply(root_object)

      # Assert
      aggregate_failures 'assert that the command service has been called twice' do
        expect(command_service).to have_received(:dispatch).with(data[0].merge(root_object: root_object).symbolize_keys).ordered
        expect(command_service).to have_received(:dispatch).with(data[1].merge(root_object: root_object).symbolize_keys).ordered
      end
    end

    it 'stores meta from each service' do
      # Arrange
      meta = {}

      # Act - Call the method
      #
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include 'Dummy1' => { reference: '123456' }, 'Dummy2' => { reference: '123456' }
    end
  end

  describe '#valid?' do
    context 'when the first command returns an invalid result' do
      let(:command_service) { class_spy(CommandService) }
      let(:positive_command_instance) { instance_spy(BaseCommand, valid?: true) }
      let(:negative_command_instance) { instance_spy(BaseCommand, valid?: false) }

      before do
        allow(command_service).to receive(:command_for).and_return(negative_command_instance, positive_command_instance)
      end

      it 'calls dispatch on the command service only for the first' do
        # Act - Call the method
        #
        result = command.valid?(root_object)

        # Assert
        expect(result).to be false
      end
    end

    context 'when both commands returns a valid result' do
      let(:command_service) { class_spy(CommandService) }
      let(:positive_command_instance) { instance_spy(BaseCommand, valid?: true) }

      before do
        allow(command_service).to receive(:command_for).and_return(positive_command_instance, positive_command_instance)
      end

      it 'calls dispatch on the command service only for the first' do
        # Act - Call the method
        #
        result = command.valid?(root_object)

        # Assert
        expect(result).to be true
      end
    end
  end
end
