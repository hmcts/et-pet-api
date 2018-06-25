require 'sidekiq/testing'
require 'sidekiq_ar_middleware/server'
Sidekiq::Testing.server_middleware do |chain|
  chain.add SidekiqArMiddleware::Server
end
