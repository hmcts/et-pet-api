class RebuildResponseCommand < BuildResponseCommand
  def apply(root_object, meta: {})
    apply_root_attributes(attributes, to: root_object)
    allocate_pdf_file(root_object)
  end

  private

  def apply_root_attributes(input_data, to:)
    to.attributes = input_data
    office_code = to.case_number[0..1]
    to.office ||= Office.find_by(code: office_code)
    to.reference ||= "#{office_code}#{reference_service.next_number}00"
    to.date_of_receipt ||= Time.zone.now
  end

  def allocate_pdf_file(root_object)
    super if root_object.pdf_file.blank?
  end
end
