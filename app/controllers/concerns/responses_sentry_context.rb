module ResponsesSentryContext
  extend ActiveSupport::Concern

  private

  def set_sentry_response(response)
    return if response&.id.blank?

    Sentry.with_scope do |scope|
      scope.set_extras(response_id: response.id)
    end
  end
end
