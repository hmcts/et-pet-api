class AssignReferenceToClaimCommand < BaseCommand
  def initialize(*)
    super
    self.reference_service = ReferenceService
    self.office_service = OfficeService
  end

  def apply(root_object, meta: {})
    if root_object.reference.blank?
      assign_office_code_for(root_object)
      generate_reference_for(root_object)
    end
    meta.merge! reference: root_object.reference
  end

  private

  attr_accessor :reference_service, :office_service

  def generate_reference_for(claim)
    reference = reference_service.next_number
    claim.reference = "#{claim.office_code}#{reference}00"
  end

  def assign_office_code_for(claim)
    resp = claim.respondents.first
    postcode_for_reference = resp.work_address.try(:post_code) || resp.address.try(:post_code)
    office = office_service.lookup_postcode(postcode_for_reference)
    claim.office_code = office.code
  end
end
