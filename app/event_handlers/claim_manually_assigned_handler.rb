class ClaimManuallyAssignedHandler
  def handle(claim:, external_systems_repo: ExternalSystem, event_service: EventService)
    external_systems_repo.containing_office_code(claim.office_code).exporting_claims.each do |external_system|
      event_service.publish('ClaimExported', external_system_id: external_system.id, claim_id: claim.id)
    end
  end
end
