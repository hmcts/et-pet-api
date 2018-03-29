require 'rails_helper'

RSpec.describe Office, type: :model do
  subject(:office) { described_class.new }

  describe '#post_codes' do
    it 'returns a collection of office post codes' do
      # Arrange
      office = Office.where(code: 22).first

      # Act
      result = office.post_codes.to_a

      # Assert
      expect(result.length).to be > 0
      expect(result.first).to be_a(OfficePostCode)
    end
  end

  describe '#default' do
    it 'returns the office with a code of 99' do
      # Act
      result = Office.default.first

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 99))
    end
  end
end
