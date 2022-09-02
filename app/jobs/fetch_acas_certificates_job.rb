# frozen_string_literal: true

class FetchAcasCertificatesJob < ApplicationJob
  class RetriableError < RuntimeError
    attr_reader :claim
    def initialize(msg, claim)
      @claim = claim
      super(msg)
    end
  end

  retry_on RuntimeError, wait: 1.minute do |job, error|
    Rails.logger.error(error)
    claim = job.arguments.first
    Raven.extra_context(claim_id: claim.id) do
      Raven.capture_exception(error)
    end
    emit_claim_prepared_event(claim)
  end

  def perform(claim, service: FetchClaimAcasCertificatesService)
    result = service.call(claim)
    if result.not_required? || result.found? || result.not_found? || result.invalid?
      emit_claim_prepared_event(claim)
      return
    end

    raise RetriableError.new(result.errors.values.flatten.join("\n"), claim)
  end

  private

  def self.needs_certificates?(claim)
    FetchClaimAcasCertificatesService.respondents_needing_acas(claim).present?
  end

  def self.emit_claim_prepared_event(claim)
    claim.events.claim_prepared.create
    EventService.publish('ClaimPrepared', claim)
  end

  def emit_claim_prepared_event(*args)
    self.class.emit_claim_prepared_event(*args)
  end
end
