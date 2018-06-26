class BuildResponseCommand < BaseCommand
  def apply(root_object, reference_service: ReferenceService)
    root_object.attributes = input_data
    office_code = root_object.case_number[0..1]
    root_object.reference = "#{office_code}#{reference_service.next_number}00"
    root_object.date_of_receipt = Time.zone.now
    meta.merge! submitted_at: root_object.date_of_receipt, reference: root_object.reference,
                office_address: Office.where(code: office_code).first.address
  end
end
