# frozen_string_literal: true

# A sidekiq job which queues async events to sidekiq
class EventJob < ApplicationJob
  queue_as :events

  def perform(handler_class, *args)
    handler_class.safe_constantize.new.handle(*args)
  end
end
