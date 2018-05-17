require 'rails_helper'
RSpec.describe OfficeService do
  subject(:service) { described_class }

  describe '.lookup_postcode' do
    it 'finds office 22 when SW1H 9ST is provided' do
      # Act
      result = service.lookup_postcode('SW1H 9ST')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 22))
    end

    it 'finds office 26 when DE1 is provided' do
      # Act
      result = service.lookup_postcode('DE1')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 26))
    end

    it 'finds office 26 when DE11 is provided' do
      # Act
      result = service.lookup_postcode('DE11')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 26))
    end

    it 'finds office 32 when E is provided' do
      # Act
      result = service.lookup_postcode('E')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 32))
    end

    it 'finds office 32 when SS is provided' do
      # Act
      result = service.lookup_postcode('SS')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 32))
    end

    it 'finds office 41 when AB1 is provided' do
      # Act
      result = service.lookup_postcode('AB1')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 41))
    end

    it 'returns the default office given a post code which is not covered using pre configured data' do
      # Act
      result = service.lookup_postcode('FF1 1AA')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 99))
    end
  end

  describe '.lookup_by_case_number' do
    it 'finds office 14 which is in seed data' do
      # Act
      result = service.lookup_by_case_number('1412345/2016')

      # Assert
      expect(result).to be_a(Office).and(have_attributes(code: 14))
    end

    it 'does not find office 76 as it is not in seed data' do
      # Act
      result = service.lookup_by_case_number('7612345/2016')

      # Assert
      expect(result).to be_nil
    end
  end
end
