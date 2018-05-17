Rails.application.config.after_initialize do
  EventService.subscribe('ResponseCreated', ResponseCreatedHandler)
end
