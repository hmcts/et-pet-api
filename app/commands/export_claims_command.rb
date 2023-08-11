class ExportClaimsCommand < BaseCommand
  attribute :external_system_id, :integer
  attribute :claim_ids

  validate :validate_external_system_presence
  validate :validate_claims_presence

  # @param [Export] root_object The export instance to populate
  # @param [Hash] meta - Not used in this command
  def apply(_root_object, meta: {})
    claim_ids.each do |claim_id|
      event_service.publish('ClaimExported', external_system_id: external_system_id, claim_id: claim_id)
    end
  end

  private

  def validate_external_system_presence
    return if ExternalSystem.where(id: external_system_id).count.positive?

    errors.add :external_system_id, :external_system_not_found,
               external_system_id: external_system_id,
               uuid: uuid,
               command: command_name
  end

  def validate_claims_presence
    return if Claim.where(id: claim_ids).count == claim_ids.length

    claim_ids.each do |claim_id|
      next unless Claim.where(id: claim_id).count.zero?

      errors.add :claim_ids, :claim_not_found,
                 claim_id: claim_id,
                 uuid: uuid,
                 command: command_name
    end
  end
end
