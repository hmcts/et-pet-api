# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlobBuiltHandler do
  subject { described_class.new }
  let(:root_object) { {} }
  describe '#handle' do
    it 'assigns urls' do
      subject.handle(root_object)

    end
  end
end
