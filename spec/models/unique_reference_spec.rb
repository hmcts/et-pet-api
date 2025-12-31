require 'rails_helper'

RSpec.describe UniqueReference do
  subject(:reference) { described_class.new }

  it 'always has an id of > 20000000' do
    reference.save
    expect(reference.id).to be > 20000000
  end

  it 'increments by 1 each time' do
    # Arrange - a previous call has been made
    first_reference = described_class.create

    # Act
    reference.save

    # Assert
    expect(reference.id - first_reference.id).to be 1
  end
end
