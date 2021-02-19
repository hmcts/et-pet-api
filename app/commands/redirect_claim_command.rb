class RedirectClaimCommand < BaseCommand
  attribute :office_id, :integer
  attribute :claim_id, :integer

  validate :validate_office_presence
  validate :validate_claim_presence

# @param [Export] root_object The export instance to populate
# @param [Hash] meta - Not used in this command
  def apply(root_object, meta: {}, external_systems_repo: ExternalSystem)
    claim.update office_code: office.code
    external_systems_repo.containing_office_code(office.code).exporting_claims.each do |external_system|
      event_service.publish('ClaimExported', external_system_id: external_system.id, claim_id: claim_id)
    end
  end

  private

  def office
    return @office if defined?(@office)

    @office = Office.where(id: office_id).first
  end

  def claim
    return @claim if defined?(@claim)

    @@claim = Claim.where(id: claim_id).first
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
