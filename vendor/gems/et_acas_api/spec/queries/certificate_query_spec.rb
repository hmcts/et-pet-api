require 'rails_helper'
RSpec.describe EtAcasApi::CertificateQuery do
  let(:user_id) { 'my_user' }
  subject(:query) { described_class.new(id: certificate_number, user_id: user_id, acas_api_service: fake_acas_api_service) }
  let(:certificate_number) { 'R123456/14/01' }
  let(:fake_acas_api_service) { instance_spy('EtAcasApi::AcasApiService', errors: {}) }
  describe '#valid?' do
    context 'with invalid certificate number' do
      let(:certificate_number) { 'S123456/14/01' }
      it 'should be false when the format of the id (certificate number) is invalid' do
        # Act
        result = query.valid?

        # Assert
        expect(result).to be false
      end
    end

  end

  describe '#status' do
    it 'should mirror what the underlying api service says' do
      # Arrange - Setup the fake acas api service to respond accordingly and create a certificate
      expect(fake_acas_api_service).to receive(:status).at_least(:once).and_return(:my_value)
      certificate = instance_double('EtAcasApi::Certificate')

      # Act
      query.apply(certificate)
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
      expect(fake_acas_api_service).to have_received(:call).with(certificate_number, user_id: 'my_user', into: certificate)
    end

    context 'with invalid certificate number' do
      let(:certificate_number) { 'S123456/14/00' }
      it 'sets status without calling the service' do
        # Arrange - Setup a certificate
        certificate = instance_double('EtAcasApi::Certificate')

        # Act
        query.apply(certificate)

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
        # Arrange - Setup a certificate
        certificate = instance_double('EtAcasApi::Certificate')

        # Act
        query.apply(certificate)

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
      # Arrange - Setup the fake acas api service to respond accordingly and create a certificate
      expect(fake_acas_api_service).to receive(:errors).at_least(:once).and_return(id: ['Some error message'])
      certificate = instance_double('EtAcasApi::Certificate')

      # Act
      query.apply(certificate)
      result = query.errors

      # Assert
      expect(result).to eql(id: ['Some error message'])
    end
  end
end
