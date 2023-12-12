require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require_relative '../app/services/event_service'
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EtApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.active_support.cache_format_version = 7.0
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ['assets', 'tasks'])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.mailer_time_zone = "London"

    def event_service
      EventService.instance
    end

    role_suffix = Sidekiq.server? ? '-SIDEKIQ' : ''
    insights_key = ENV.fetch('AZURE_APP_INSIGHTS_KEY', false)
    if insights_key
      config.azure_insights.enable = true
      config.azure_insights.key = insights_key
      config.azure_insights.role_name = ENV.fetch('AZURE_APP_INSIGHTS_ROLE_NAME', 'et-api') + role_suffix
      config.azure_insights.role_instance = ENV.fetch('HOSTNAME', 'all')
      config.azure_insights.buffer_size = 500
      config.azure_insights.send_interval = 60
    else
      config.azure_insights.enable = false
    end

    config.govuk_notify = ActiveSupport::OrderedOptions.new
    config.govuk_notify.custom_url = ENV.fetch('GOVUK_NOTIFY_CUSTOM_URL', false)
    if ENV.key?('GOVUK_NOTIFY_API_KEY_LIVE')
      config.govuk_notify.enabled = true
      config.govuk_notify.live_api_key = ENV['GOVUK_NOTIFY_API_KEY_LIVE']
      config.govuk_notify.team_api_key = ENV.fetch('GOVUK_NOTIFY_API_KEY_TEAM', nil)
      config.govuk_notify.test_api_key = ENV.fetch('GOVUK_NOTIFY_API_KEY_TEST', nil)
      config.govuk_notify.mode = :live
    else
      config.govuk_notify.enabled = false
    end

    config.redis_host = ENV.fetch('REDIS_HOST', 'localhost')
    config.redis_port = ENV.fetch('REDIS_PORT', '6379')
    config.redis_database = ENV.fetch('REDIS_DATABASE', '2')
    default_redis_url = "redis://#{config.redis_host}:#{config.redis_port}"
    config.redis_url = ENV.fetch('REDIS_URL', default_redis_url) + "/#{config.redis_database}"
    config.flatten_pdf = ENV.fetch('FLATTEN_PDF', "false") == 'true'

    config.file_conversions = ActiveSupport::OrderedOptions.new
    config.file_conversions.enabled = ENV.fetch('FILE_CONVERSIONS_ENABLED', 'true') == 'true'
    config.file_conversions.allowed_types = ['application/rtf']
  end
end
