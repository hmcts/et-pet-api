require 'rails_helper'

RSpec.describe Office do
  subject(:office) { described_class.new }

  describe '#post_codes' do
    it 'returns a collection of office post codes' do
      # Arrange
      office = described_class.where(code: 22).first

      # Act
      result = office.post_codes.to_a

      # Assert
      expect(result.first).to be_a(OfficePostCode)
    end
  end

  describe '#default' do
    it 'returns the office with a code of 99' do
      # Act
      result = described_class.default.first

      # Assert
      expect(result).to be_a(described_class).and(have_attributes(code: 99))
    end
  end
end
