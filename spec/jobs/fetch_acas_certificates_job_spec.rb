require 'rails_helper'

describe FetchAcasCertificatesJob do
  include ActiveJob::TestHelper
  describe 'perform' do
    let(:claim) { create(:claim) }
    let!(:fake_service) { class_double(FetchClaimAcasCertificatesService, call: fake_service_response).as_stubbed_const }
    before do
      allow(Sentry).to receive(:set_extras).and_call_original
      allow(Sentry).to receive(:capture_exception)
    end
    context 'with successful found service response' do
      let(:fake_service_response) { instance_double(FetchClaimAcasCertificatesService, found?: true, not_found?: false, not_required?: false, acas_server_error?: false, invalid?: false, errors: {}) }
      it 'emits claim prepared event' do
        described_class.perform_now(claim)
        expect(claim.events.claim_prepared).to be_present
      end

      it 'does not enqueue any more jobs' do
        assert_no_enqueued_jobs only: described_class do
          described_class.perform_now(claim, service: fake_service)
        end
      end

      it 'has not called sentry' do
        described_class.perform_now(claim)
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end

    context 'with successful but not found service response' do
      let(:fake_service_response) { instance_double(FetchClaimAcasCertificatesService, found?: false, not_found?: true, not_required?: false, acas_server_error?: false, invalid?: false, errors: {}) }
      it 'emits claim prepared event' do
        described_class.perform_now(claim)
        expect(claim.events.claim_prepared).to be_present
      end

      it 'does not enqueue any more jobs' do
        assert_no_enqueued_jobs only: described_class do
          described_class.perform_now(claim)
        end
      end

      it 'has not called sentry' do
        described_class.perform_now(claim)
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end

    context 'with unsuccessful service response due to server error' do
      let(:fake_service_response) { instance_double(FetchClaimAcasCertificatesService, found?: false, not_found?: false, not_required?: false, acas_server_error?: true, invalid?: false, errors: {base: ['Something went wrong']}) }
      it 'does not emit claim prepared event' do
        described_class.perform_now(claim)
        expect(claim.events.claim_prepared).not_to be_present
      end

      it 'enqueues a retry' do
        assert_enqueued_jobs 1, only: described_class do
          described_class.perform_now(claim)
        end
      end

      it 'has not called sentry' do
        described_class.perform_now(claim)
        expect(Sentry).not_to have_received(:capture_exception)
      end

      it 'has not called sentry after 4 retries' do
        described_class.perform_now(claim)
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        expect(Sentry).not_to have_received(:capture_exception)
      end

      it 'calls sentry after 5 retries' do
        described_class.perform_now(claim)
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        expect(Sentry).to have_received(:capture_exception).with(an_object_having_attributes(message: 'Something went wrong'))
      end

      it 'emits claim prepared event after 5 retries' do
        described_class.perform_now(claim)
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        expect(claim.events.claim_prepared).to be_present
      end

      it 'does not emit claim prepared event after 4 retries' do
        described_class.perform_now(claim)
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        expect(claim.events.claim_prepared).not_to be_present
      end

      it 'has no more jobs enqueued after 5 retries' do
        described_class.perform_now(claim)
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        perform_enqueued_jobs only: described_class
        assert_no_enqueued_jobs only: described_class
      end
    end

    context 'with unsuccessful service response due to a validation error' do
      let(:fake_service_response) { instance_double(FetchClaimAcasCertificatesService, found?: false, not_found?: false, not_required?: false, acas_server_error?: false, invalid?: true, errors: {id: ['Invalid certificate format']}) }
      it 'emits claim prepared event' do
        described_class.perform_now(claim)
        expect(claim.events.claim_prepared).to be_present
      end

      it 'does not enqueue any more jobs' do
        assert_no_enqueued_jobs only: described_class do
          described_class.perform_now(claim)
        end
      end

      it 'has not called sentry' do
        described_class.perform_now(claim)
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end
  end
end
