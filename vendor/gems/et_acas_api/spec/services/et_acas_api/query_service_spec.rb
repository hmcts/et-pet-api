require 'rails_helper'

RSpec.describe EtAcasApi::QueryService do
  subject(:service) { described_class }

  describe '.dispatch' do
    context 'with a valid query' do
      let(:query_instance) { instance_spy('EtAcasApi::DummyQuery').tap { |instance| allow(instance).to receive(:apply).and_return instance } }
      let(:query_class) { class_spy('EtAcasApi::DummyQuery', new: query_instance).as_stubbed_const }
      let(:data) { { anything: :goes } }
      let(:root_object) { Object.new }

      before do
        query_class
      end

      it 'creates a new instance of the query' do
        # Act - call dispatch
        service.dispatch query: 'Dummy',
                         root_object: root_object,
                         my_param1: 'test',
                         my_param2: 'test2'

        # Assert - Make sure the query class received new with the correct params
        expect(query_class).to have_received(:new).with(my_param1: 'test', 'my_param2': 'test2')
      end

      it 'calls apply on the query with the root object passed in' do
        # Act - call dispatch
        service.dispatch query: 'Dummy',
                         root_object: root_object,
                         my_param1: 'test',
                         my_param2: 'test2'

        # Assert - Make sure the query instance receives apply with the root object passed
        expect(query_instance).to have_received(:apply).with(root_object)
      end

      it 'returns the query' do
        # Act - call dispatch
        result = service.dispatch query: 'Dummy',
                                  root_object: root_object,
                                  my_param1: 'test',
                                  my_param2: 'test2'

        # Assert - Make sure the query instance is returned
        expect(result).to be query_instance
      end
    end
  end
end
