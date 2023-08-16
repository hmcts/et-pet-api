class AssignClaimCommand < BaseCommand
  attribute :office_id, :integer
  attribute :claim_id, :integer
  attribute :user_id, :integer

  validate :validate_office_presence
  validate :validate_claim_presence

  # @param [Export] root_object The export instance to populate
  # @param [Hash] meta - Not used in this command
  def apply(_root_object, meta: {}) # rubocop:disable Lint/UnusedMethodArgument
    claim.update office_code: office.code
    claim.events.claim_manually_assigned.create data: { office_code: office.code, user_id: user_id }
    event_service.publish('ClaimManuallyAssigned', claim: claim)
  end

  private

  def office
    return @office if defined?(@office)

    @office = Office.where(id: office_id).first
  end

  def claim
    return @claim if defined?(@claim)

    @claim = Claim.where(id: claim_id).first
  end

  def validate_office_presence
    return if office.present?

    errors.add :office_id, :office_not_found,
               office_id: office_id,
               uuid: uuid,
               command: command_name
  end

  def validate_claim_presence
    return if claim.present?

    errors.add :claim_id, :claim_not_found,
               claim_id: claim_id,
               uuid: uuid,
               command: command_name
  end
end
