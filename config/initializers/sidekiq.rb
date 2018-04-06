default_redis_host = ENV.fetch('REDIS_HOST', 'localhost')
default_redis_port = ENV.fetch('REDIS_PORT', '6379')
default_redis_database = ENV.fetch('REDIS_DATABASE', '1')
default_redis_url = "redis://#{default_redis_host}:#{default_redis_port}/#{default_redis_database}"
redis_url = ENV.fetch('REDIS_URL', default_redis_url)

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  schedule_file = "config/schedule.yml"

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load(ERB.new(File.read(schedule_file)).result)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end