class BuildClaimCommand < BaseCommand
  attribute :reference, :string
  attribute :submission_reference, :string
  attribute :submission_channel, :string
  attribute :case_type, :string
  attribute :jurisdiction, :string
  attribute :office_code, :string
  attribute :date_of_receipt, :string
  attribute :other_known_claimant_names, :string
  attribute :discrimination_claims
  attribute :pay_claims
  attribute :desired_outcomes
  attribute :other_claim_details, :string
  attribute :claim_details, :string
  attribute :other_outcome, :string
  attribute :send_claim_to_whistleblowing_entity, :boolean
  attribute :miscellaneous_information, :string
  attribute :employment_details
  attribute :is_unfair_dismissal, :boolean

  def initialize(*)
    super
    self.reference_service = ReferenceService
  end

  def apply(root_object, meta: {})
    apply_root_attributes(attributes, to: root_object)
    meta.merge! reference: root_object.reference
  end

  private

  attr_accessor :reference_service

  def apply_root_attributes(input_data, to:)
    to.attributes = input_data
  end
end
