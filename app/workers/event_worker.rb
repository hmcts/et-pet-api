# frozen_string_literal: true

# A sidekiq worker which queues async events to sidekiq
class EventWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'events'

  def perform(handler_class, *args)
    handler_class.safe_constantize.new.handle(*args)
  end
end
