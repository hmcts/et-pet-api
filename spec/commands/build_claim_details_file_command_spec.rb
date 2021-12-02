require 'rails_helper'

RSpec.describe BuildClaimDetailsFileCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_file_data, :simple_user_with_rtf).as_json.stringify_keys }
  let(:root_object) { create(:claim) }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)
      root_object.save!

      # Assert
      expect(root_object.uploaded_files.user_file_scope).to include an_object_having_attributes(data.except('data_from_key', 'data_url'))
    end
  end
end
