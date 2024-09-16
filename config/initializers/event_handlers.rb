Rails.application.config.after_initialize do |app|
  app.event_service.subscribe('ResponseCreated', PrepareResponseHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponseRecreated', ReprepareResponseHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponseRepairRequested', ResponseRepairRequestedHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponsePrepared', ResponseExportHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponseOfficeAssigned', ResponseEmailHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponseExported', ResponseExportedHandler, async: true, in_process: false)
  app.event_service.subscribe('ClaimCreated', PrepareClaimFilesHandler, async: true, in_process: false)
  app.event_service.subscribe('ClaimImported', PrepareImportedClaimHandler, async: true, in_process: false)
  app.event_service.subscribe('ClaimExported', ClaimExportedHandler, async: true, in_process: false)
  app.event_service.subscribe('ClaimManuallyAssigned', ClaimManuallyAssignedHandler, async: false, in_process: true)
  app.event_service.subscribe('ClaimPrepared', ClaimExportHandler, async: false, in_process: true)
  app.event_service.subscribe('ClaimFilesPrepared', PrepareClaimHandler, async: false, in_process: true)
  app.event_service.subscribe('ClaimPrepared', ClaimEmailHandler, async: true, in_process: false)
  app.event_service.subscribe('BlobCreated', BlobCreatedHandler, async: false, in_process: true)
  app.event_service.subscribe('ReferenceCreated', ReferenceCreatedHandler, async: false, in_process: true)
  app.event_service.subscribe('ResponseExportFeedbackReceived', ResponseExportFeedbackReceivedHandler, async: false,
                                                                                                       in_process: true)
end
