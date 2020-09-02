class ClaimExportHandler
  def handle(claim)
    ExternalSystem.containing_office_code(claim.office_code).where(enabled: true).each do |system|
      export = Export.claims.create resource: claim, external_system_id: system.id if system.always_save_export? || system.export_claims?
      if system.export_claims?
        claim.events.claim_queued_for_export.create(data: { export_id: export.id, external_system_id: system.id })
        Rails.application.event_service.publish('ClaimQueuedForExport', export)
      end
    end
  end
end
