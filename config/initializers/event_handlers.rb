Rails.application.config.after_initialize do
  EventService.subscribe('ResponseCreated', ResponseCreatedHandler)
  EventService.subscribe('SignedS3FormDataCreated', SignedS3FormDataCreatedHandler)
end
