Rails.application.config.after_initialize do
  EventService.subscribe('ResponseCreated', ResponseCreatedHandler, async: true, in_process: false)
  EventService.subscribe('ClaimCreated', ClaimCreatedHandler, async: true, in_process: false)
  EventService.subscribe('SignedS3FormDataCreated', SignedS3FormDataCreatedHandler, async: false, in_process: true)
  EventService.subscribe('ReferenceCreated', ReferenceCreatedHandler, async: false, in_process: true)
end
