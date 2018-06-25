require 'sidekiq/testing'
Sidekiq::Testing.server_middleware do |chain|
  chain.add SidekiqArMiddleware::Server
end
