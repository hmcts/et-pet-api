require 'rails_helper'

RSpec.describe CreateSignedS3FormDataCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data, async: false) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { { preventEmptyData: nil } }
  let(:root_object) { {} }

  describe '#apply' do
    it 'does nothing' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to be_empty
    end
  end
end
