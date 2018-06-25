require 'sidekiq'
require 'sidekiq/testing'
require "sidekiq_ar_middleware/version"
require "sidekiq_ar_middleware/railtie"
require "sidekiq_ar_middleware/client"
require "sidekiq_ar_middleware/server"
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
  Sidekiq::Testing.server_middleware do |chain|
    chain.add Server
  end
end
