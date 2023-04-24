require 'sidekiq/testing'
Sidekiq::Testing.fake!
RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Queues.clear_all
  end
end

