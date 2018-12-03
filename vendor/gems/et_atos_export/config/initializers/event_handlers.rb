Rails.application.config.after_initialize do |app|
  app.event_service.subscribe('ClaimMultipleClaimantsImported', EtAtosExport::ExportClaimHandler, async: false, in_process: true)
  app.event_service.subscribe('ResponseCreated', EtAtosExport::ExportResponseHandler, async: true, in_process: false)
end
