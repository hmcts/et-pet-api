class RepairClaimCommand < BaseCommand
  attribute :claim_id

  validate :validate_claim_presence

# @param [Hash] root_object Not used - nothing to update from using this command
# @param [Hash] meta - Not used in this command
  def apply(root_object, meta: {})
    event_service.publish('ClaimCreated', claim)
  end

  private

  def claim
    return @claim if defined?(@claim)

    @claim = Claim.find_by(id: claim_id)
  end

  def validate_claim_presence
    return if claim.present?

    errors.add :claim_id, :claim_not_found,
               claim_id: claim_id,
               uuid: uuid,
               command: command_name
  end
end
