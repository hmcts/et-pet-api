require 'rails_helper'
RSpec.describe EtAcasApi::CertificateQuery do
  let(:user_id) { 'my_user' }
  subject(:query) { described_class.new(ids: [certificate_number], user_id: user_id, acas_api_service: fake_acas_api_service) }
  let(:certificate_number) { 'R123456/14/01' }
  let(:fake_acas_api_service) { instance_spy('EtAcasApi::V1::AcasApiService', errors: {}) }
  describe '#valid?' do
    context 'with invalid collection number' do
      let(:certificate_number) { 'S123456/14/01' }
      it 'should be false when the format of the id (collection number) is invalid' do
        # Act
        result = query.valid?

        # Assert
        expect(result).to be false
      end
    end

  end

  describe '#status' do
    it 'should mirror what the underlying api service says' do
      # Arrange - Setup the fake acas api service to respond accordingly and create a collection
      expect(fake_acas_api_service).to receive(:status).at_least(:once).and_return(:my_value)
      root_object = []

      # Act
      query.apply(root_object)
      result = query.status

      # Assert
      expect(result).to be :my_value
    end
  end

  describe '#apply' do
    it 'request that the underlying service populates the root object (collection) when found' do
      # Arrange - Setup a collection
      root_object = []

      # Act
      query.apply(root_object)

      # Assert - Ensure the service was called
      expect(fake_acas_api_service).to have_received(:call).with([certificate_number], user_id: 'my_user', into: root_object)
    end

    context 'with invalid collection number' do
      let(:certificate_number) { 'S123456/14/00' }
      it 'sets status without calling the service' do
        # Arrange - Setup a collection
        collection = []

        # Act
        query.apply(collection)

        # Assert - Ensure the service was not called, the status is set and the errors contain the correct error
        aggregate_failures 'service not called and status set' do
          expect(fake_acas_api_service).not_to have_received(:call)
          expect(query.status).to be :invalid_certificate_format
          expect(query.errors).to include id: a_collection_including('Invalid certificate format')
        end
      end
    end

    context 'with nil user_id' do
      let(:user_id) { nil }
      it 'sets status without calling the service' do
        # Arrange - Setup a collection
        collection = []

        # Act
        query.apply(collection)

        # Assert - Ensure the service was not called, the status is set and the errors contain the correct error
        aggregate_failures 'service not called and status set' do
          expect(fake_acas_api_service).not_to have_received(:call)
          expect(query.status).to be :invalid_user_id
          expect(query.errors).to include user_id: a_collection_including('Missing user id')
        end
      end
    end
  end

  describe '#errors' do
    it  'should mirror what the underlying api service says' do
      # Arrange - Setup the fake acas api service to respond accordingly and create a collection
      expect(fake_acas_api_service).to receive(:errors).at_least(:once).and_return(id: ['Some error message'])
      collection = []

      # Act
      query.apply(collection)
      result = query.errors

      # Assert
      expect(result).to eql(id: ['Some error message'])
    end
  end

  describe '#initialize' do
    context 'using api_version 1' do
      let!(:fake_acas_api_service_class) { class_spy('EtAcasApi::V1::AcasApiService', new: 'anything').as_stubbed_const }
      subject(:query) { described_class.new(ids: [certificate_number], user_id: user_id, api_version: 1) }

      it 'uses version 1 of the service' do
        subject
        expect(fake_acas_api_service_class).to have_received(:new)
      end
    end

    context 'using api_version 2' do
      let!(:fake_acas_api_service_class) { class_spy('EtAcasApi::V2::AcasApiService', new: 'anything').as_stubbed_const }
      subject(:query) { described_class.new(ids: [certificate_number], user_id: user_id, api_version: 2) }

      it 'uses version 2 of the service' do
        subject
        expect(fake_acas_api_service_class).to have_received(:new)
      end
    end

    context 'using the default api_version' do
      let!(:fake_acas_api_service_class) { class_spy('EtAcasApi::V1::AcasApiService', new: 'anything').as_stubbed_const }
      subject(:query) { described_class.new(ids: [certificate_number], user_id: user_id) }

      it 'uses version 1 of the service' do
        subject
        expect(fake_acas_api_service_class).to have_received(:new)
      end

    end
  end
end
