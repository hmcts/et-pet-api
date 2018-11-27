class ClaimExportHandler
  def handle(claim, export_service: ClaimExportService)
    export_service.new(claim).to_be_exported
    Rails.application.event_service.publish('ClaimQueuedForExport', claim)
  end
end
