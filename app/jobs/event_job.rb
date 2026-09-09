# frozen_string_literal: true

# A job which queues async events to active job
class EventJob < ApplicationJob
  queue_as :events

  def perform(handler_class, *args, **kw_args)
    handler_class.safe_constantize.new.handle(*args, **kw_args)
  end
end
