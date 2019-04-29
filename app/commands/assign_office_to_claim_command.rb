class AssignOfficeToClaimCommand < BaseCommand
  def initialize(*args, office_service: OfficeService, **kw_args)
    super(*args, **kw_args)
    self.office_service = office_service
  end

  def apply(root_object, meta: {})
    office = office_for(root_object)
    assign_office_code_for(root_object, office)
    assign_office_meta_for(meta, office)
  end

  private

  attr_accessor :office_service

  def assign_office_code_for(claim, office)
    claim.office_code = office.code
  end

  def assign_office_meta_for(meta, office)
    meta[:office] = {
      name: office.name,
      code: office.code,
      telephone: office.telephone,
      address: office.address,
      email: office.email
    }
  end

  def office_for(claim)
    resp = claim.primary_respondent
    postcode_for_reference = resp.work_address.try(:post_code) || resp.address.try(:post_code)
    office_service.lookup_postcode(postcode_for_reference)
  end
end
