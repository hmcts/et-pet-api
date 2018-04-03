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
end
