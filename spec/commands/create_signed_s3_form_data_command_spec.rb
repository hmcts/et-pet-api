require 'rails_helper'

RSpec.describe CreateSignedS3FormDataCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data, async: false) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { { anything: :goes} }
  let(:root_object) { {} }

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to include(anything: :goes)
    end
  end
end
