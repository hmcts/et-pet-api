require 'rails_helper'

describe ClaimEmailHandler do
  subject(:handler) { described_class.new }

  include_context 'with gov uk notify emails sent monitor'

  let(:claim) { create(:claim, :with_pdf_file, confirmation_email_recipients: ['fred@bloggs.com']) }

  describe '#handle' do
    it 'sends 1 email when called twice' do
      handler.handle(claim)
      handler.handle(claim)
      expect(emails_sent.new_claim_email_count_for(reference: claim.reference, template_reference: claim.email_template_reference)).to be 1
    end

    context 'with english template v1, a pdf file, no claim details file and no csv' do
      it 'sends the email correctly' do
        handler.handle(claim)
        expect(emails_sent.new_claim_email_for(reference: claim.reference, template_reference: claim.email_template_reference)).to have_correct_contents_from_db_for(claim)
      end
    end

    context 'with english template v1, a pdf file, a claim details file  and no csv' do
      let(:claim) { create(:claim, :with_pdf_file, :with_input_claim_details_file, :with_output_claim_details_file, confirmation_email_recipients: ['fred@bloggs.com']) }

      it 'sends the email correctly' do
        handler.handle(claim)
        expect(emails_sent.new_claim_email_for(reference: claim.reference, template_reference: claim.email_template_reference)).to have_correct_contents_from_db_for(claim)
      end
    end

    context 'with english template v1, a pdf file, a claim details file and a csv' do
      let(:claim) { create(:claim, :with_pdf_file, :with_input_claim_details_file, :with_output_claim_details_file, :with_claimants_csv_file, confirmation_email_recipients: ['fred@bloggs.com']) }

      it 'sends the email correctly' do
        handler.handle(claim)
        expect(emails_sent.new_claim_email_for(reference: claim.reference, template_reference: claim.email_template_reference)).to have_correct_contents_from_db_for(claim)
      end
    end

    context 'with welsh template v1, a pdf file, no claim details file and no csv' do
      let(:claim) { create(:claim, :with_welsh_email, :with_pdf_file, confirmation_email_recipients: ['fred@bloggs.com']) }

      it 'sends the email correctly' do
        handler.handle(claim)
        expect(emails_sent.new_claim_email_for(reference: claim.reference, template_reference: claim.email_template_reference)).to have_correct_contents_from_db_for(claim)
      end
    end

    context 'with welsh template v1, a pdf file, a claim details file and no csv' do
      let(:claim) { create(:claim, :with_welsh_email, :with_pdf_file, :with_input_claim_details_file, :with_output_claim_details_file, confirmation_email_recipients: ['fred@bloggs.com']) }

      it 'sends the email correctly' do
        handler.handle(claim)
        expect(emails_sent.new_claim_email_for(reference: claim.reference, template_reference: claim.email_template_reference)).to have_correct_contents_from_db_for(claim)
      end
    end

    context 'with welsh template v1, a pdf file, a claim details file and a csv' do
      let(:claim) { create(:claim, :with_welsh_email, :with_pdf_file, :with_input_claim_details_file, :with_output_claim_details_file, :with_claimants_csv_file, confirmation_email_recipients: ['fred@bloggs.com']) }

      it 'sends the email correctly' do
        handler.handle(claim)
        expect(emails_sent.new_claim_email_for(reference: claim.reference, template_reference: claim.email_template_reference)).to have_correct_contents_from_db_for(claim)
      end
    end
  end

end
