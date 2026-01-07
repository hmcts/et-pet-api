# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative do
  subject(:rep) { described_class.new }

  let(:example_address_attrs) { attributes_for(:address) }

  it 'allows building of the address using nested attributes' do
    # Act
    rep.address_attributes = example_address_attrs

    # Assert
    expect(rep.address).to have_attributes example_address_attrs
  end
end
