class ClaimExportHandler
  def handle(claim)
    ExternalSystem.containing_office_code(claim.office_code).where(enabled: true).each do |system|
      export = Export.claims.create resource: claim, external_system_id: system.id if system.always_save_export? || system.export_claims?
      Rails.application.event_service.publish('ClaimQueuedForExport', export) if system.export_claims?
    end
  end
end
