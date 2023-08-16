# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Claimant, type: :model do
  subject(:claimant) { described_class.new }

  let(:example_address_attributes) { attributes_for(:address) }

  describe '#address' do
    it 'can be built from nested attributes' do
      # Arrange
      claimant.address_attributes = example_address_attributes

      # Act
      address = claimant.address

      # Assert
      expect(address).to have_attributes example_address_attributes
    end
  end
end
