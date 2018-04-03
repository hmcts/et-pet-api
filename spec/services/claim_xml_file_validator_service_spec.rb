# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ClaimXmlFileValidatorService do
  describe '#valid?' do
    it 'is true when the correct checksum for the file is given' do
      inputs = {
        'first_last.pdf' => {
          file: first_last_pdf_tempfile,
          checksum: first_last_pdf_checksum
        }
      }
      subject = described_class.new(inputs)
      expect(subject.valid?).to be true
    end
  end
end
