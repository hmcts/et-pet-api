class ClaimExportedHandler
  def handle(external_system_id:, claim_id:, event_service: Rails.application.event_service)
    export = Export.create! external_system_id: external_system_id, resource_id: claim_id, resource_type: 'Claim', state: 'created'
    Event.claim_queued_for_export.create(attached_to_id: claim_id, attached_to_type: 'Claim', data: { export_id: export.id, external_system_id: external_system_id })
    event_service.publish('ClaimQueuedForExport', export)
  end
end
