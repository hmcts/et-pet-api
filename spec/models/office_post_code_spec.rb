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

      # Assert - according to the seed data, the best match is SW1H
      expect(office_post_code).to have_attributes(postcode: 'SW1H')
    end

    it 'returns the correct office post code with a full post code given without space seperating' do
      # Arrange
      office_post_code = OfficePostCode.with_partial_match('SW1H9ST').first

      # Assert - according to the seed data, the best match is SW1H
      expect(office_post_code).to have_attributes(postcode: 'SW1H')
    end

    it 'returns the correct office post code with a full post code whose first section ends in 1 but list has 1 and 10 entries e.g. BA1 - BA10' do
      # Arrange
      office_post_code = OfficePostCode.with_partial_match('BA1 9ZT').first

      # Assert - according to the seed data, the best match is BA1
      expect(office_post_code).to have_attributes(postcode: 'BA1')
    end

    it 'returns the correct office post code with a full post code whose first section ends in 10 but list has 1 and 10 entries e.g. BA1 - BA10' do
      # Arrange
      office_post_code = OfficePostCode.with_partial_match('BA10 9QA').first

      # Assert - according to the seed data, the best match is BA10
      expect(office_post_code).to have_attributes(postcode: 'BA10')
    end

    it 'returns the correct office post code with a full post code whose first section does not exist but a shorter version does' do
      # Arrange
      office_post_code = OfficePostCode.with_partial_match('E15 9PQ').first

      # Assert - according to the seed data, the best match is BA10
      expect(office_post_code).to have_attributes(postcode: 'E')
    end
  end
end
