# frozen_string_literal: true

class SolidQueueTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(*)
    puts "SolidQueueTestJob perform"
    Rails.logger.info "SolidQueueTestJob perform"
  end
end
