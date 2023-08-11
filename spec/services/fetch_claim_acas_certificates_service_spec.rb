require 'rails_helper'

describe FetchClaimAcasCertificatesService do
  describe '.call' do
    subject(:service) { described_class.call(claim) }

    context 'with claim containing 1 respondent with acas cert number' do
      let(:claim) { create(:claim, :example_data) }

      it 'returns object with found? returning true' do
        expect(subject.found?).to be true
      end

      it 'adds an event to the claim showing the success' do
        subject
        expect(claim.events.claim_acas_requested.count).to be 1
      end

      it 'returns object with acas_server_error? returning true when service times out' do
        stub_request(:any, /fakeservice\.com/).to_timeout
        expect(subject.acas_server_error?).to be true
      end

      it 'adds an event to the claim when the service times out' do
        stub_request(:any, /fakeservice\.com/).to_timeout
        subject
        expect(claim.events.claim_acas_attempt_failed).to be_present
      end
    end
  end
end
