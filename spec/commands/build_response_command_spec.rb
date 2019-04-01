require 'rails_helper'

RSpec.describe BuildResponseCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_response_data, :full, case_number: '2234567/2016').as_json }
  let(:root_object) { Response.new }

  include_context 'with disabled event handlers'

  describe '#apply' do
    it 'applies the data to the root object' do
      # Act
      command.apply(root_object, meta: {})

      # Assert (some fields cannot be easily validated as the response AR model will convert them)
      expect(root_object).to have_attributes(data.except(:additional_information_key, :employment_end, :employment_start, :queried_hours, :queried_pay_before_tax, :queried_take_home_pay))
    end

    it 'creates a new reference and stores it in the root object' do
      # Act
      command.apply(root_object)

      # Assert
      office_code = data[:case_number][0..1]
      expect(root_object.reference).to match(/\A#{office_code}\d{8}00\z/)
    end

    it 'stores the reference in the meta hash' do
      # Setup
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include(reference: root_object.reference)
    end

    it 'adds todays datetime to the date_of_receipt' do
      # Setup
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(root_object.date_of_receipt).to be_within(1.minute).of(Time.zone.now)
    end

    it 'adds todays datetime to the meta[submitted_at]' do
      # Setup
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta[:submitted_at]).to be_within(1.minute).of(Time.zone.now)
    end

    it 'adds the office data to the meta[address]' do
      # Setup
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include(office_address: 'Victory House, 30-34 Kingsway, London WC2B 6EX')
    end

    it 'adds the office phone number to the meta[office_phone_number]' do
      # Setup
      meta = {}

      # Act
      command.apply(root_object, meta: meta)

      # Assert
      expect(meta).to include(office_phone_number: '020 7273 8603')
    end
  end

  describe '#valid?' do
    let(:office) { Office.first }
    let(:office_code) { "%02d" % office.code }

    context 'with invalid case number' do
      let(:data) do
        {
          case_number: '0034567/2016'
        }
      end

      it 'is false' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the case_number attribute' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:case_number]).to include(error: :invalid_office_code)
      end
    end

    context 'with valid case number' do
      let(:data) do
        {
          case_number: "#{office_code}34567/2016"
        }
      end

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end

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

    context 'with invalid email_template_reference' do
      let(:data) do
        {
          email_template_reference: '../../../etc/password'
        }
      end

      it 'contains the correct error key in the email_template_reference attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:email_template_reference]).to include(error: :inclusion, value: data[:email_template_reference])
      end

    end
  end
end
