class ClaimExportHandler
  def handle(claim)
    ExternalSystem.containing_office_code(claim.office_code).each do |system|
      export = Export.claims.create resource: claim, external_system_id: system.id
      Rails.application.event_service.publish('ClaimQueuedForExport', export)
    end
  end
end
