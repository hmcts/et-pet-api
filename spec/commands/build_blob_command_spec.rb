require 'rails_helper'

RSpec.describe BuildBlobCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data, async: false) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { { preventEmptyData: nil } }
  let(:root_object) { {} }
  let(:meta) { {} }

  describe '#apply' do
    it 'leaves the root object empty' do
      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(root_object).to be_empty
    end

    it 'sets the meta[:cloud_provider]' do
      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include cloud_provider: an_instance_of(String)
    end
  end
end
