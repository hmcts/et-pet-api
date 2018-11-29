class ClaimExportHandler
  def handle(claim)
    ExternalSystem.containing_office_code(claim.office_code).each do |system|
      Export.claims.create resource: claim, external_system_id: system.id
    end
    Rails.application.event_service.publish('ClaimQueuedForExport', claim)
  end
end
