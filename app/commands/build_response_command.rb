class BuildResponseCommand < BaseCommand
  def initialize(*)
    super
    self.reference_service = ReferenceService
    self.allocator_service = UploadedFileAllocatorService.new
  end

  def apply(root_object)
    apply_root_attributes(input_data, to: root_object)
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
end
