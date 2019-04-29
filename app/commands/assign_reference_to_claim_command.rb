class AssignReferenceToClaimCommand < BaseCommand
  def initialize(*args, reference_service: ReferenceService, **kw_args)
    super(*args, **kw_args)
    self.reference_service = reference_service
  end

  def apply(root_object, meta: {})
    if root_object.reference.blank?
      generate_reference_for(root_object)
    end
    meta.merge! reference: root_object.reference
  end

  private

  attr_accessor :reference_service

  def generate_reference_for(claim)
    reference = reference_service.next_number
    claim.reference = "#{claim.office_code}#{reference}00"
  end
end
