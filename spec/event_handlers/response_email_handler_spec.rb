require 'rails_helper'

describe ResponseEmailHandler do
  subject(:handler) { described_class.new }

  include_context 'with gov uk notify emails sent monitor'

  let(:response) { create(:response, :with_pdf_file, email_receipt: 'fred@bloggs.com') }

  describe '#handle' do
    it 'sends 1 email when called twice' do
      handler.handle(response)
      handler.handle(response)

      expect(ActionMailer::Base.deliveries.length).to be 1
    end

    describe 'v1' do
      context 'with english template' do
        let(:response) { create(:response, :with_english_v1_template, :with_pdf_file, email_receipt: 'fred@bloggs.com')}

        it 'sends the email via SMTP correctly' do
          handler.handle(response)
          expect(ActionMailer::Base.deliveries.length).to be 1
        end
      end

      context 'with welsh template' do
        let(:response) { create(:response, :with_welsh_v1_template, :with_pdf_file, email_receipt: 'fred@bloggs.com')}

        it 'sends the email via SMTP correctly' do
          handler.handle(response)
          expect(ActionMailer::Base.deliveries.length).to be 1
        end
      end
    end

    context 'with english template v2' do
      it 'sends the email correctly' do
        handler.handle(response)
        expect(emails_sent.new_response_email_for(reference: response.reference, template_reference: response.email_template_reference)).to have_correct_contents_from_db_for(response)
      end
    end

    context 'with welsh template v2' do
      let(:response) { create(:response, :with_welsh_email_v2, email_receipt: ['fred@bloggs.com']) }

      it 'sends the email correctly' do
        handler.handle(response)
        expect(emails_sent.new_response_email_for(reference: response.reference, template_reference: response.email_template_reference)).to have_correct_contents_from_db_for(response)
      end
    end
  end

end
