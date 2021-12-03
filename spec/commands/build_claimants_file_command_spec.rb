require 'rails_helper'

RSpec.describe BuildClaimantsFileCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_file_data, :simple_user_with_csv_group_claims).as_json.stringify_keys }
  let(:root_object) { Claim.new }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object.uploaded_files.filter(&:user_file_scope?)).to include an_object_having_attributes(data.except('data_from_key', 'data_url'))
    end
  end
end
