class TriggerEventJob < ApplicationJob
  queue_as :events

  def initialize(event_service: Rails.application.event_service)
    self.event_service = event_service
    super()
  end

  def perform(event, data)
    Rails.logger.debug { "An event #{event} was raised from the outside world - re raising internally" }
    event_service.publish(event, data)
  end

  private

  attr_accessor :event_service
end
