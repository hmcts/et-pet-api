class AssignReferenceToClaimCommand < BaseCommand
  def initialize(*)
    super
    self.reference_service = ReferenceService
    self.office_service = OfficeService
  end

  def apply(root_object)
    generate_reference_for(root_object) if root_object.reference.blank?
    meta.merge! reference: root_object.reference
  end

  private

  attr_accessor :reference_service, :office_service

  def generate_reference_for(claim)
    resp = claim.respondents.first
    postcode_for_reference = resp.work_address.try(:post_code) || resp.address.try(:post_code)
    reference = reference_service.next_number
    office = office_service.lookup_postcode(postcode_for_reference)
    claim.reference = "#{office.code}#{reference}00"
  end
end
