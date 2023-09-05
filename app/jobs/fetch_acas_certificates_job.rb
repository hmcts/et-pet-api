# frozen_string_literal: true

class FetchAcasCertificatesJob < ApplicationJob
  sidekiq_options(retry: false)
  class RetriableError < RuntimeError
    attr_reader :claim

    def initialize(msg, claim)
      @claim = claim
      super(msg)
    end
  end

  retry_on Exception, wait: 1.minute do |job, error|
    Rails.logger.error(error)
    claim = job.arguments.first
    Sentry.with_scope do |scope|
      scope.set_extras(claim_id: claim.id)
      Sentry.capture_exception(error)
    end
    emit_claim_prepared_event(claim)
  end

  def perform(claim, service: FetchClaimAcasCertificatesService)
    return if claim.events.claim_prepared.present?

    result = service.call(claim)
    if result.not_required? || result.found? || result.not_found? || result.invalid?
      emit_claim_prepared_event(claim)
      return
    end

    raise RetriableError.new(result.errors.values.flatten.join("\n"), claim) # rubocop:disable Rails/DeprecatedActiveModelErrorsMethods
  end

  def self.needs_certificates?(claim)
    FetchClaimAcasCertificatesService.respondents_needing_acas(claim).present?
  end

  def self.emit_claim_prepared_event(claim)
    claim.events.claim_prepared.create
    EventService.publish('ClaimPrepared', claim)
  end

  private

  def emit_claim_prepared_event(*args)
    self.class.emit_claim_prepared_event(*args)
  end

end
