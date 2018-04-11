# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Respondent, type: :model do
  subject(:respondent) { described_class.new }
  let(:example_address_attrs) { attributes_for :address }

  it 'loads address from nested attributes' do
    # Act
    respondent.address_attributes = example_address_attrs

    # Assert
    expect(respondent.address).to have_attributes example_address_attrs
  end

  it 'loads work_address from nested attributes' do
    # Arrange
    example_address_attrs = attributes_for :address
    # Act
    respondent.work_address_attributes = example_address_attrs

    # Assert
    expect(respondent.work_address).to have_attributes example_address_attrs
  end
end
