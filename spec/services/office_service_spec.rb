require 'rails_helper'
RSpec.describe OfficeService do
  subject(:service) { described_class }

  describe '#lookup_postcode' do
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
end
