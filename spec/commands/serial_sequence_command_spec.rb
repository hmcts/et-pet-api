require 'rails_helper'

RSpec.describe SerialSequenceCommand do
  shared_context 'with fake command service' do
    # A command like it is declared in the app

    let(:my_command_class) do
      Class.new(::BaseCommand) do
        attribute :my_attribute

        validate :check_not_blank

        def check_not_blank
          errors.add :my_attribute, "It is blank", error: :blank if my_attribute.blank?
        end
      end
    end

    before do
      self.class.const_set('MyCommand', my_command_class)
    end

    after do
      self.class.send(:remove_const, 'MyCommand') if self.class.const_defined?('MyCommand')
    end

    # A command response is simply a proxy for the command but also stores the meta
    let(:my_command_response_class) do
      Class.new do
        def initialize(command:, meta: {})
          self.command = command
          self.meta = meta
        end
        attr_accessor :command, :meta

        delegate_missing_to :command
      end
    end
    let(:command_service) { class_double(CommandService) }

    include_context 'with disabled event handlers'
  end

  shared_context 'with fake commands from data' do
    let(:command1) { my_command_class.new(data[0].symbolize_keys) }
    let(:command2) { my_command_class.new(data[1].symbolize_keys) }
    before do
      allow(command_service).to receive(:command_for).with(**data[0].symbolize_keys).and_return(command1)
      allow(command_service).to receive(:command_for).with(**data[1].symbolize_keys).and_return(command2)
      allow(command_service).to receive(:dispatch).with(command: command1, root_object: anything).and_return(my_command_response_class.new(command: command1, meta: { reference: '123456' }))
      allow(command_service).to receive(:dispatch).with(command: command2, root_object: anything).and_return(my_command_response_class.new(command: command2, meta: { reference: '789123' }))
    end
  end

  subject(:command) { described_class.new(uuid: uuid, data: data, command_service: command_service) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) do
    [
      {
        command: 'Dummy1',
        uuid: SecureRandom.uuid,
        data: { my_attribute: :dontcare }
      }.with_indifferent_access,
      {
        command: 'Dummy2',
        uuid: SecureRandom.uuid,
        data: { my_attribute: :dontcare }
      }.with_indifferent_access
    ]
  end
  let(:root_object) { Object.new }

  describe '#apply' do
    include_context 'with fake command service'
    include_context 'with fake commands from data'

    it 'calls dispatch on the command service for each command in the data' do
      # Act - Call the method
      #
      command.apply(root_object)

      # Assert
      aggregate_failures 'assert that the command service has been called twice' do
        expect(command_service).to have_received(:dispatch).with(command: command1, root_object: root_object)
        expect(command_service).to have_received(:dispatch).with(command: command2, root_object: root_object)
      end
    end

    it 'stores meta from each service' do
      # Arrange
      meta = {}

      # Act - Call the method
      #
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include 'Dummy1' => { reference: '123456' }, 'Dummy2' => { reference: '789123' }
    end
  end

  describe '#valid?' do
    include_context 'with fake command service'
    include_context 'with fake commands from data'

    context 'when the first command returns an invalid result' do
      let(:data) do
        [
          {
            command: 'Dummy1',
            uuid: 'fakeuuid1',
            data: {}
          }.with_indifferent_access,
          {
            command: 'Dummy2',
            uuid: 'fakeuuid2',
            data: { my_attribute: :dontcare }
          }.with_indifferent_access
        ]
      end

      it 'is invalid' do
        # Act - Call the method
        #
        result = command.valid?(root_object)

        # Assert
        expect(result).to be false
      end

      it 'reports the errors in a nested indexed format' do
        # Act - Call the method
        #
        command.valid?(root_object)

        # Assert
        expect(command.errors.details[:'data[0].my_attribute']).to include(error: :blank, command: 'Dummy1', uuid: 'fakeuuid1')
      end

      it 'reports the error message in a nested indexed format' do
        # Act - Call the method
        #
        command.valid?(root_object)

        # Assert
        expect(command.errors.messages[:'data[0].my_attribute']).to include('It is blank')
      end
    end

    context 'when the second command returns an invalid result' do
      let(:data) do
        [
          {
            command: 'Dummy1',
            uuid: 'fakeuuid1',
            data: { my_attribute: :dontcare }
          }.with_indifferent_access,
          {
            command: 'Dummy2',
            uuid: 'fakeuuid2',
            data: {}
          }.with_indifferent_access
        ]
      end

      it 'is invalid' do
        # Act - Call the method
        #
        result = command.valid?(root_object)

        # Assert
        expect(result).to be false
      end

      it 'reports the errors in a nested indexed format' do
        # Act - Call the method
        #
        command.valid?(root_object)

        # Assert
        expect(command.errors.details[:'data[1].my_attribute']).to include(error: :blank, command: 'Dummy2', uuid: 'fakeuuid2')
      end

      it 'reports the error message in a nested indexed format' do
        # Act - Call the method
        #
        command.valid?(root_object)

        # Assert
        expect(command.errors.messages[:'data[1].my_attribute']).to include('It is blank')
      end
    end

    context 'when both commands returns a valid result' do
      let(:data) do
        [
          {
            command: 'Dummy1',
            uuid: SecureRandom.uuid,
            data: { my_attribute: :dontcare }
          }.with_indifferent_access,
          {
            command: 'Dummy2',
            uuid: SecureRandom.uuid,
            data: { my_attribute: :dontcare }
          }.with_indifferent_access
        ]
      end

      it 'is valid' do
        # Act - Call the method
        #
        result = command.valid?(root_object)

        # Assert
        expect(result).to be true
      end
    end
  end
end
