Rails.application.config.after_initialize do
  ::EventService.subscribe('ClaimMultipleClaimantsImported', EtAtosExport::ExportClaimHandler, async: true, in_process: false)
end
