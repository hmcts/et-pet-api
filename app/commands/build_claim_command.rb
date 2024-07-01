class BuildClaimCommand < BaseCommand
  attribute :reference, :string
  attribute :submission_reference, :string
  attribute :submission_channel, :string
  attribute :case_type, :string
  attribute :jurisdiction, :string
  attribute :office_code, :string
  attribute :date_of_receipt, :string
  attribute :other_known_claimant_names, :string
  attribute :other_known_claimants, :boolean
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
  attribute :pdf_template_reference, :string, default: 'et1-v4-en'
  attribute :email_template_reference, :string, default: 'et1-v1-en'
  attribute :confirmation_email_recipients, default: []
  attribute :time_zone, :string, default: 'London'
  attribute :was_employed, :boolean
  attribute :is_whistleblowing, :boolean
  attribute :whistleblowing_regulator_name, :string
  validates :pdf_template_reference, inclusion: { in: ['et1-v1-en', 'et1-v1-cy', 'et1-v2-en', 'et1-v2-cy', 'et1-v3-en', 'et1-v3-cy', 'et1-v4-en', 'et1-v4-cy'] }
  validates :email_template_reference, inclusion: { in: ['et1-v1-en', 'et1-v1-cy'] }
  validates :time_zone, inclusion: { in: ['London'] }

  def initialize(*args, reference_service: ReferenceService, **kw_args)
    super(*args, **kw_args)
    self.reference_service = reference_service
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
