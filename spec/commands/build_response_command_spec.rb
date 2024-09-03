require 'rails_helper'

RSpec.describe BuildResponseCommand do
  subject(:command) { described_class.new(uuid: uuid, data: data).tap(&:valid?) }

  let(:uuid) { SecureRandom.uuid }
  let(:data) { build(:json_response_data, :full, case_number: '2234567/2016').as_json }
  let(:root_object) { Response.new }

  around do |example|
    ActiveStorage::Current.set(url_options: { host: 'www.example.com' }) do
      example.run
    end
  end

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
  end

  describe '#valid?' do
    let(:office) { Office.first }
    let(:office_code) { "%02d" % office.code }

    context 'with invalid case number' do
      let(:data) { attributes_for(:json_response_data, :full, case_number: '0034567/2016') }

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
      let(:data) { attributes_for(:json_response_data, :full, case_number: "#{office_code}34567/2016") }

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end

    context 'with invalid pdf_template_reference' do
      let(:data) { attributes_for(:json_response_data, :full, pdf_template_reference: '../../../etc/password') }

      it 'contains the correct error key in the pdf_template_reference attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:pdf_template_reference]).to include(error: :inclusion, value: data[:pdf_template_reference])
      end

    end

    context 'with invalid email_template_reference' do
      let(:data) { attributes_for(:json_response_data, :full, email_template_reference: '../../../etc/password') }

      it 'contains the correct error key in the email_template_reference attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:email_template_reference]).to include(error: :inclusion, value: data[:email_template_reference])
      end

    end

    context 'with queried_hours at maximum' do
      let(:data) { attributes_for(:json_response_data, :full, queried_hours: 168) }

      it 'is true' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be true
      end
    end

    context 'with queried hours over maximum' do
      let(:data) { attributes_for(:json_response_data, :full, queried_hours: 168.01) }

      it 'is false' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the queried_hours attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:queried_hours]).to include(hash_including(error: :less_than_or_equal_to, value: be_within(0.001).of(data[:queried_hours]), count: 168.0))
      end
    end

    context 'with queried hours over the database limit' do
      let(:data) { attributes_for(:json_response_data, :full, queried_hours: 1000.0) }

      it 'is false' do
        # Act
        result = command.valid?

        # Assert
        expect(result).to be false
      end

      it 'contains the correct error key in the queried_hours attributes' do
        # Act
        command.valid?

        # Assert
        expect(command.errors.details[:queried_hours]).to include(hash_including(error: :less_than_or_equal_to, value: be_within(0.001).of(data[:queried_hours]), count: 168))
      end
    end
  end
end
