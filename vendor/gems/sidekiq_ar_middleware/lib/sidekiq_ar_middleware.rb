require 'sidekiq'
require "sidekiq_ar_middleware/version"
require "sidekiq_ar_middleware/railtie"
require "sidekiq_ar_middleware/client"
require "sidekiq_ar_middleware/server"
require "sidekiq_ar_middleware/testing" if Rails.env == 'test'
module SidekiqArMiddleware
  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add Client
    end
  end
  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Server
    end
  end
end
