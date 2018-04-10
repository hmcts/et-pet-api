# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Claimant, type: :model do
  subject(:claimant) { described_class.new }

  describe '#address' do
    it 'can be built from nested attributes' do
      # Arrange
      claimant.address_attributes = {
        building: '102',
        street: 'Petty France',
        locality: 'London',
        county: 'Greater London',
        post_code: 'SW1H 9AJ'
      }

      # Act
      address = claimant.address

      # Assert
      expect(address).to have_attributes building: '102',
                                         street: 'Petty France',
                                         locality: 'London',
                                         county: 'Greater London',
                                         post_code: 'SW1H 9AJ'
    end
  end
end
