require 'rails_helper'
RSpec.describe ReferenceService do
  subject(:service) { described_class }

  describe '#next_numner' do
    it 'is an integer' do
      expect(service.next_number).to be_a(Integer)
    end

    it 'generates 2 sequential values when called twice' do
      result1 = service.next_number
      result2 = service.next_number

      expect(result2).to be > result1
    end
  end
end
