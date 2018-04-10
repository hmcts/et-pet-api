# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Respondent, type: :model do
  subject(:respondent) { described_class.new }

  it 'loads address from nested attributes' do
    # Act
    respondent.address_attributes = {
      building: '102',
      street: 'Petty France',
      locality: 'London',
      county: 'Greater London',
      post_code: 'SW1H 9AJ'
    }

    # Assert
    expect(respondent.address).to have_attributes building: '102',
                                                  street: 'Petty France',
                                                  locality: 'London',
                                                  county: 'Greater London',
                                                  post_code: 'SW1H 9AJ'
  end

  it 'loads work_address from nested attributes' do
    # Act
    respondent.work_address_attributes = {
      building: '102',
      street: 'Petty France',
      locality: 'London',
      county: 'Greater London',
      post_code: 'SW1H 9AJ'
    }

    # Assert
    expect(respondent.work_address).to have_attributes building: '102',
                                                       street: 'Petty France',
                                                       locality: 'London',
                                                       county: 'Greater London',
                                                       post_code: 'SW1H 9AJ'
  end
end
