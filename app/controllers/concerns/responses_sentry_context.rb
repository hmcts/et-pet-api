module ResponsesSentryContext
  extend ActiveSupport::Concern

  private

  def set_sentry_response(response)
    return unless response&.id.present?

    Sentry.with_scope do |scope|
      scope.set_extras(response_id: response.id)
    end
  end
end
