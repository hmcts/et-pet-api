class BuildResponseCommand < BaseCommand
  def apply(root_object, reference_service: ReferenceService)
    root_object.attributes = data
    office_code = root_object.case_number[0..1]
    root_object.reference = "#{office_code}#{reference_service.next_number}00"
    meta[:reference] = root_object.reference
  end
end
