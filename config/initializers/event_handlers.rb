Rails.application.config.after_initialize do |app|
  app.event_service.subscribe('ResponseCreated', ResponseCreatedHandler, async: true, in_process: false)
  app.event_service.subscribe('ClaimCreated', ClaimImportMultipleClaimantsHandler, async: true, in_process: false)
  app.event_service.subscribe('SignedS3FormDataCreated', SignedS3FormDataCreatedHandler, async: false, in_process: true)
  app.event_service.subscribe('ReferenceCreated', ReferenceCreatedHandler, async: false, in_process: true)
end
