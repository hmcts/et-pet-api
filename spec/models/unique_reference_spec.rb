require 'rails_helper'

RSpec.describe UniqueReference, type: :model do
  subject(:reference) { described_class.new }
  it 'always has an id of > 20000000' do
    reference.save
    expect(reference.id).to be > 20000000
  end
end
