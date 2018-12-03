class ClaimExportHandler
  def handle(claim)
    Export.claims.create resource: claim
    Rails.application.event_service.publish('ClaimQueuedForExport', claim)
  end
end
