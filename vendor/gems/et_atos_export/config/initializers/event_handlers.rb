Rails.application.config.after_initialize do |app|
  app.event_service.subscribe('ClaimMultipleClaimantsImported', EtAtosExport::ExportClaimHandler, async: true, in_process: false)
end
