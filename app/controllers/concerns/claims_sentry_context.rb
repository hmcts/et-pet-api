module ClaimsSentryContext
  extend ActiveSupport::Concern

  private

  def set_sentry_claim(claim)
    return if claim&.id.blank?

    Sentry.with_scope do |scope|
      scope.set_extras(claim_id: claim.id)
    end
  end
end
