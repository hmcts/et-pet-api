# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Claim, type: :model do
  subject(:claim) { described_class.new }
  describe '#claimants' do
    it 'returns claimants built in memory' do
      # Arrange
      claim.claimants_attributes = [
        {
          title: 'Mr',
          first_name: 'Fred',
          last_name: 'Bloggs',
          address_attributes: {
            building: '102',
            street: 'Petty France',
            locality: 'London',
            county: 'Greater London',
            post_code: 'SW1H 9AJ'
          }
        }
      ]

      # Act
      results = claim.claimants

      # Assert
      expect(claim.claimants).to contain_exactly an_object_having_attributes first_name: 'Fred', last_name: 'Bloggs'
    end
  end

  describe '#respondents' do
    it 'returns respondents built in memory' do
      # Arrange
      claim.respondents_attributes = [
        {
          name: 'Fred Bloggs',
          address_attributes: {
            building: '102',
            street: 'Petty France',
            locality: 'London',
            county: 'Greater London',
            post_code: 'SW1H 9AJ'
          },
          work_address_telephone_number: '03333 423554',
          address_telephone_number: '02222 321654',
          acas_number: 'AC123456/78/90',
          work_address_attributes: {
            building: '102',
            street: 'Petty France',
            locality: 'London',
            county: 'Greater London',
            post_code: 'SW1H 9AJ'
          },
          alt_phone_number: '03333 423554'
        }
      ]

      # Assert - Validate the results
      expect(claim.respondents).to contain_exactly an_object_having_attributes name: 'Fred Bloggs'
    end
  end

  describe '#representatives' do
    it 'returns representatives built in memory' do
      # Arrange
      claim.representatives_attributes = [
        {
          name: 'Solicitor Name',
          organisation_name: 'Solicitors Are Us Fake Company',
          address_attributes: {
            building: '106',
            street: 'Mayfair',
            locality: 'London',
            county: 'Greater London',
            post_code: 'SW1H 9PP'
          },
          address_telephone_number: '01111 123456',
          mobile_number: '02222 654321',
          email_address: 'solicitor.test@digital.justice.gov.uk',
          representative_type: 'Solicitor',
          dx_number: 'dx1234567890'
        }
      ]

      # Act
      reps = claim.representatives

      # Assert
      expect(reps).to contain_exactly an_object_having_attributes name: 'Solicitor Name'
    end
  end

  describe '#uploaded_files' do
    it 'returns uploaded files built in memory' do
      # Act
      claim.uploaded_files_attributes = [
        {
          filename: 'et1_first_last.pdf',
          checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
          file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
        }
      ]

      # Assert
      expect(claim.uploaded_files).to contain_exactly an_object_having_attributes filename: 'et1_first_last.pdf'
    end
  end

  # @TODO Security - make sure first and last names cannot contain anything that might screw up the file copying
end
