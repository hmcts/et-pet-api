redis_url = Rails.application.config.redis_url

Sidekiq.configure_server do |config|
  redis_config = { url: redis_url }
  redis_config[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD'].present?
  config.redis = redis_config
  schedule_file = "config/schedule.yml"
  puts("Sidekiq server configured with url #{redis_url}")

  Redis.new

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.safe_load(ERB.new(File.read(schedule_file)).result)
  end

end

Sidekiq.configure_client do |config|
  redis_config = { url: redis_url }
  redis_config[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD'].present?
  config.redis = redis_config
  puts("Sidekiq client configured with url #{redis_url}")
end

Sidekiq.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'debug').upcase)
