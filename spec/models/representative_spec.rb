# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative, type: :model do
  subject(:rep) { described_class.new }

  it 'allows building of the address using nested attributes' do
    # Act
    rep.address_attributes = {
      building: '102',
      street: 'Petty France',
      locality: 'London',
      county: 'Greater London',
      post_code: 'SW1 9AJ'
    }

    # Assert
    expect(rep.address).to have_attributes building: '102',
                                           street: 'Petty France',
                                           locality: 'London',
                                           county: 'Greater London',
                                           post_code: 'SW1 9AJ'
  end
end
