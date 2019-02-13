Rails.application.config.after_initialize do |app|
  app.event_service.subscribe('ResponsePreparedForAtosExport', ResponsePdfFileHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponsePdfFileAdded', ResponseExportHandler, async: false, in_process: true)
  app.event_service.subscribe('ResponsePdfFileAdded', ResponseEmailHandler, async: false, in_process: true)
  app.event_service.subscribe('ClaimCreated', ClaimImportMultipleClaimantsHandler, async: true, in_process: false)
  app.event_service.subscribe('ClaimPreparedForAtosExport', ClaimExportHandler, async: false, in_process: true)
  app.event_service.subscribe('SignedS3FormDataCreated', SignedS3FormDataCreatedHandler, async: false, in_process: true)
  app.event_service.subscribe('BlobBuilt', BlobBuiltHandler, async: false, in_process: true)
  app.event_service.subscribe('ReferenceCreated', ReferenceCreatedHandler, async: false, in_process: true)
end
