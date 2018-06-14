require 'rails_helper'
RSpec.describe EtAcasApi::CertificateQuery do
  subject(:query) { described_class.new(id: 'anything', user_id: 'my_user', acas_api_service: fake_acas_api_service) }
  let(:fake_acas_api_service) { instance_spy('EtAcasApi::AcasApiService') }
  describe '#valid?' do
    it 'should be true when the api service status is :found' do
      # Arrange - Setup the fake acas api service to respond accordingly
      expect(fake_acas_api_service).to receive(:status).and_return(:found)

      # Act
      result = query.valid?

      # Assert
      expect(result).to be true
    end

    it 'should be false when the api service status is :not_found' do
      # Arrange - Setup the fake acas api service to respond accordingly
      expect(fake_acas_api_service).to receive(:status).and_return(:not_found)

      # Act
      result = query.valid?

      # Assert
      expect(result).to be false
    end

    it 'should be false when the api service status is :invalid_certificate_format' do
      # Arrange - Setup the fake acas api service to respond accordingly
      expect(fake_acas_api_service).to receive(:status).and_return(:invalid_certificate_format)

      # Act
      result = query.valid?

      # Assert
      expect(result).to be false
    end

    it 'should be false when the api service status is :acas_server_error' do
      # Arrange - Setup the fake acas api service to respond accordingly
      expect(fake_acas_api_service).to receive(:status).and_return(:acas_server_error)

      # Act
      result = query.valid?

      # Assert
      expect(result).to be false
    end

  end

  describe '#status' do
    it 'should mirror what the underlying api service says' do
      # Arrange - Setup the fake acas api service to respond accordingly
      expect(fake_acas_api_service).to receive(:status).and_return(:my_value)

      # Act
      result = query.status

      # Assert
      expect(result).to be :my_value
    end
  end

  describe '#apply' do
    it 'request that the underlying service populates the root object (certificate) when found' do
      # Arrange - Setup a certificate
      certificate = instance_double('EtAcasApi::Certificate')

      # Act
      query.apply(certificate)

      # Assert - Ensure the service was called
      expect(fake_acas_api_service).to have_received(:call).with('anything', user_id: 'my_user', into: certificate)
    end
  end

  describe '#errors' do
    it  'should mirror what the underlying api service says' do
      # Arrange - Setup the fake acas api service to respond accordingly
      expect(fake_acas_api_service).to receive(:errors).and_return(id: ['Some error message'])

      # Act
      result = query.errors

      # Assert
      expect(result).to eql(id: ['Some error message'])
    end
  end
end
