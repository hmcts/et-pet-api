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
  attribute :pdf_template_reference, :string, default: 'et1-v1-en'

  validates :pdf_template_reference, inclusion: { in: ['et1-v1-en', 'et1-v1-cy'] }

  def initialize(*)
    super
    self.reference_service = ReferenceService
    self.allocator_service = UploadedFileAllocatorService.new
  end

  def apply(root_object, meta: {})
    apply_root_attributes(attributes, to: root_object)
    allocate_pdf_file(root_object)
    meta.merge! reference: root_object.reference,
                pdf_url: allocator_service.allocated_url
  end

  private

  attr_accessor :reference_service, :allocator_service

  def allocate_pdf_file(root_object)
    allocator_service.allocate('et1_atos_export.pdf', into: root_object)
  end

  def apply_root_attributes(input_data, to:)
    to.attributes = input_data
  end
end
