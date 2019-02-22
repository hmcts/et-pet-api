# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Response, type: :model do
  subject(:response) { described_class.new }

  describe '#additional_information_rtf_file?' do
    context 'with an attached file' do
      subject(:response) { build(:response, :example_data, :with_input_rtf_file) }

      it 'returns true' do
        expect(response.additional_information_rtf_file?).to be true
      end
    end

    context 'with no attached file' do
      subject(:response) { build(:response, :example_data) }

      it 'returns false' do
        expect(response.additional_information_rtf_file?).to be false
      end
    end
  end

  describe '#office' do
    subject(:response) { build(:response) }

    it 'returns the correct office with the code matching the first 2 chars of the reference' do
      expect(response.office).to be_a(Office).and(have_attributes(code: 22))
    end
  end
end
