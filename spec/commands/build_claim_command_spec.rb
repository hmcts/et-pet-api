require 'rails_helper'

RSpec.describe BuildClaimCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_claim_data, :full, reference: 'myreference').as_json }
  let(:root_object) { build(:claim) }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object)

      # Assert
      expect(root_object).to have_attributes(data.except(:date_of_receipt, :jurisdiction, :office_code)).
        and(have_attributes(jurisdiction: data[:jurisdiction].to_i, office_code: data[:office_code].to_i)).
        and(have_attributes(date_of_receipt: an_instance_of(ActiveSupport::TimeWithZone)))
    end

    it 'adds a reference to the meta' do
      # Arrange
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include reference: data[:reference]
    end
  end

  describe '#valid?' do
    context 'with invalid pdf_template_reference' do
      let(:data) do
        {
          pdf_template_reference: '../../../etc/password'
        }
      end

      it 'contains the correct error key in the pdf_template_reference attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:pdf_template_reference]).to include(error: :inclusion, value: data[:pdf_template_reference])
      end

    end
  end
end
