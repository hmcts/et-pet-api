Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.action_controller.default_url_options = { host: 'example.com' }

  # Configure active job to always use async as it is more like real life
  config.active_job.queue_adapter = :async

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false
  config.action_mailer.default_options = { from: 'no-reply@digital.justice.gov.uk' }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # These settings for acas api will be modified once we know exactly what we are doing with them.
  # for now, we are using the test environment settings otherwise the app wont boot.
  if ENV.key?('RSA_ACAS_PUBLIC_CERTIFICATE_BASE64')
    config.et_acas_api.acas_rsa_certificate = Base64.decode64(ENV['RSA_ACAS_PUBLIC_CERTIFICATE_BASE64'].gsub(/\\n/, "\n"))
  else
    config.et_acas_api.acas_rsa_certificate = File.read(ENV.fetch('RSA_ACAS_PUBLIC_CERTIFICATE', File.absolute_path(Rails.root.join('vendor', 'gems', 'et_acas_api', 'spec', 'acas_interface_support', 'x509', 'theirs', 'publickey.cer'), __dir__)))
  end

  if ENV.key?('RSA_ET_PUBLIC_CERTIFICATE_BASE64')
    config.et_acas_api.rsa_certificate = Base64.decode64(ENV.fetch('RSA_ET_PUBLIC_CERTIFICATE_BASE64').gsub(/\\n/, "\n"))
  else
    config.et_acas_api.rsa_certificate = File.read(ENV.fetch('RSA_ET_PUBLIC_CERTIFICATE', File.absolute_path(Rails.root.join('vendor', 'gems', 'et_acas_api', 'spec', 'acas_interface_support', 'x509', 'ours', 'publickey.cer'), __dir__)))
  end

  if ENV.key?('RSA_ET_PRIVATE_KEY_BASE64')
    config.et_acas_api.rsa_private_key = Base64.decode64(ENV.fetch('RSA_ET_PRIVATE_KEY_BASE64').gsub(/\\n/, "\n"))
  else
    config.et_acas_api.rsa_private_key = File.read(ENV.fetch('RSA_ET_PRIVATE_KEY', File.absolute_path(Rails.root.join('vendor', 'gems', 'et_acas_api', 'spec', 'acas_interface_support', 'x509', 'ours', 'privatekey.pem'), __dir__)))
  end
  config.et_acas_api.server_time_zone = 'Europe/London'
  config.et_acas_api.service_url = ENV.fetch('ACAS_SERVICE_URL', 'https://testec.acas.org.uk/Lookup/ECService.svc')

  config.et_atos_api.username = 'atos'
  config.et_atos_api.password = 'password'
end
