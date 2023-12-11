require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', :local).to_sym
  config.active_storage.service_urls_expire_in = 10.days

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false
  config.action_mailer.default_options = { from: ENV.fetch('SMTP_FROM', 'no-reply@localhost') }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  if ENV.fetch('ACTIVE_JOB_ADAPTER', 'none') != 'none'
    config.active_job.queue_adapter = ENV['ACTIVE_JOB_ADAPTER'].to_sym
  end

  config.redis_database = ENV.fetch('REDIS_DATABASE', '1')
  default_redis_url = "redis://#{config.redis_host}:#{config.redis_port}/#{config.redis_database}"
  config.redis_url = ENV.fetch('REDIS_URL', default_redis_url)

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # These settings for acas api will be modified once we know exactly what we are doing with them.
  # for now, we are using the test environment settings otherwise the app wont boot.

  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'debug').to_sym
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.et_acas_api.server_time_zone = 'Europe/London'
  config.et_acas_api.api_version = 2
  config.et_acas_api.json_subscription_key = 'testsubscriptionkey'
  config.et_acas_api.json_service_url = ENV.fetch('ACAS_JSON_SERVICE_URL', 'http://localhost:3001/ECCLJson')

  config.hosts.clear

  config.azure_insights.enable = false
end
