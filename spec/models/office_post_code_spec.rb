require 'rails_helper'

RSpec.describe OfficePostCode, type: :model do
  subject(:office_post_code) { OfficePostCode.new }

  describe '#office' do
    it 'returns the correct office' do
      # Arrange
      # In the seed data, BA1 is present against office code 14
      office_post_code = OfficePostCode.where(postcode: 'BA1').first

      # Act
      result = office_post_code.office

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 14))
    end
  end

  describe 'class#with_partial_match' do
    it 'returns the correct office post code with a full post code given with space seperating' do
      # Arrange
      office_post_code = OfficePostCode.with_partial_match('SW1H 9ST').first

      expect(office_post_code).to be_present
    end
  end
end
