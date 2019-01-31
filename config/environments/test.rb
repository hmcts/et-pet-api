Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Configure active job to always use test mode to avoid executing unescessary event handlers etc.. on tests that
  # dont want it.

  config.active_job.queue_adapter = :test

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_controller.default_url_options = { host: 'example.com' }

  # As we do some s3 specific stuff, we have to use an s3 server for testing (local server called minio)
  config.active_storage.service = ENV.fetch('CLOUD_PROVIDER', 'amazon').to_sym

  config.action_mailer.perform_caching = false
  config.action_mailer.default_options = { from: 'no-reply@digital.justice.gov.uk' }

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  #
  config.et_acas_api.acas_rsa_certificate = File.read(File.absolute_path(Rails.root.join('vendor', 'gems', 'et_acas_api', 'spec', 'acas_interface_support', 'x509', 'theirs', 'publickey.cer'), __dir__))
  config.et_acas_api.rsa_certificate = File.read(File.absolute_path(Rails.root.join('vendor', 'gems', 'et_acas_api', 'spec', 'acas_interface_support', 'x509', 'ours', 'publickey.cer'), __dir__))
  config.et_acas_api.rsa_private_key = File.read(File.absolute_path(Rails.root.join('vendor', 'gems', 'et_acas_api', 'spec', 'acas_interface_support', 'x509', 'ours', 'privatekey.pem'), __dir__))
  config.et_acas_api.server_time_zone = 'Europe/London'
  config.et_acas_api.service_url = 'http://fakeservice.com/Lookup/ECService.svc'
end
