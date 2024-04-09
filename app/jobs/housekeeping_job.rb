# frozen_string_literal: true

# A sidekiq job which queues async events to sidekiq
class HousekeepingJob < ApplicationJob
  queue_as :default

  def perform(*)
    HousekeepingService.call
  end
end
