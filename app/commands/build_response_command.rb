class BuildResponseCommand < BaseCommand
  attribute :case_number, :string
  attribute :agree_with_employment_dates, :boolean
  attribute :defend_claim, :boolean
  attribute :claimants_name, :string
  attribute :agree_with_early_conciliation_details, :boolean
  attribute :disagree_conciliation_reason, :string
  attribute :employment_start, :date
  attribute :employment_end, :date
  attribute :disagree_employment, :string
  attribute :continued_employment, :boolean
  attribute :agree_with_claimants_description_of_job_or_title, :boolean
  attribute :disagree_claimants_job_or_title, :string
  attribute :agree_with_claimants_hours, :boolean
  attribute :queried_hours, :float
  attribute :agree_with_earnings_details, :boolean
  attribute :queried_pay_before_tax, :float
  attribute :queried_pay_before_tax_period, :string
  attribute :queried_take_home_pay, :float
  attribute :queried_take_home_pay_period, :string
  attribute :agree_with_claimant_notice, :boolean
  attribute :disagree_claimant_notice_reason, :string
  attribute :agree_with_claimant_pension_benefits, :boolean
  attribute :disagree_claimant_pension_benefits_reason, :string
  attribute :defend_claim_facts, :string
  attribute :make_employer_contract_claim, :boolean
  attribute :claim_information, :string
  attribute :email_receipt, :string
  attribute :pdf_template_reference, :string, default: 'et3-v1-en'
  attribute :email_template_reference, :string, default: 'et3-v1-en'

  validate :validate_office_code_in_case_number
  validates :pdf_template_reference, inclusion: { in: ['et3-v1-en', 'et3-v1-cy'] }
  validates :email_template_reference, inclusion: { in: ['et3-v1-en', 'et3-v1-cy'] }

  def initialize(*)
    super
    self.reference_service = ReferenceService
    self.allocator_service = UploadedFileAllocatorService.new
  end

  def apply(root_object, meta: {})
    apply_root_attributes(attributes, to: root_object)
    allocate_pdf_file(root_object)
    meta.merge! submitted_at: root_object.date_of_receipt, reference: root_object.reference,
                office_address: root_object.office.address,
                office_phone_number: root_object.office.telephone,
                pdf_url: allocator_service.allocated_url
  end

  private

  attr_accessor :reference_service, :allocator_service

  def allocate_pdf_file(root_object)
    allocator_service.allocate('et3_atos_export.pdf', into: root_object)
  end

  def apply_root_attributes(input_data, to:)
    to.attributes = input_data
    office_code = to.case_number[0..1]
    to.reference = "#{office_code}#{reference_service.next_number}00"
    to.date_of_receipt = Time.zone.now
  end

  def validate_office_code_in_case_number
    return if case_number.nil? || office_present?

    errors.add(:case_number, :invalid_office_code)
  end

  def office_present?
    office_code = case_number[0..1]
    Office.where(code: office_code.to_i).present?
  end
end
