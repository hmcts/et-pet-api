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
        expect(query_class).to have_received(:new).with(my_param1: 'test', 'my_param2': 'test2', acas_api_service: instance_of(EtAcasApi::V2::AcasApiService))
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

      it 'uses v2 of the api when configured' do
        # Arrange - setup the fake service class
        fake_service_class = class_spy('EtAcasApi::V2::AcasApiService').as_stubbed_const
        # Act - call dispatch
        service.dispatch query: 'Dummy',
                                  root_object: root_object,
                                  my_param1: 'test',
                                  my_param2: 'test2',
                                  api_version: 2
        expect(fake_service_class).to have_received(:new)
      end

      it 'uses the version of the api specified in app config by default' do
        # Arrange - setup the fake service class
        version = Rails.configuration.et_acas_api.api_version
        fake_service_class = class_spy("EtAcasApi::V#{version}::AcasApiService").as_stubbed_const
        # Act - call dispatch
        result = service.dispatch query: 'Dummy',
                                  root_object: root_object,
                                  my_param1: 'test',
                                  my_param2: 'test2'
        expect(fake_service_class).to have_received(:new)
      end
    end
  end

  describe '.supports_multi?' do
    it 'is delegates to the service class and returns a positive value' do
      # Arrange - setup the fake service class
      fake_service_class = class_spy('EtAcasApi::V2::AcasApiService', supports_multi?: true).as_stubbed_const
      # Act - call dispatch
      result = service.supports_multi? api_version: 2
      expect(fake_service_class).to have_received(:supports_multi?)
      expect(result).to be true
    end
  end
end
