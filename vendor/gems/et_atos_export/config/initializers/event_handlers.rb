Rails.application.config.after_initialize do |app|
  app.event_service.subscribe('ClaimPrepared', EtAtosExport::ExportClaimHandler, async: true, in_process: false)
  app.event_service.subscribe('ResponsePrepared', EtAtosExport::ExportResponseHandler, async: true, in_process: false)
end
