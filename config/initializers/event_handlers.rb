Rails.application.config.after_initialize do
  EventService.subscribe('ResponseCreated', ResponseCreatedHandler, async: true, in_process: false)
  EventService.subscribe('ClaimAutoReferenceCreated', ClaimAutoReferenceCreatedHandler, async: true, in_process: false)
  EventService.subscribe('SignedS3FormDataCreated', SignedS3FormDataCreatedHandler, async: false, in_process: true)
end
