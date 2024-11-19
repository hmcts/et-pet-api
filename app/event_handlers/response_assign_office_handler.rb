class ResponseAssignOfficeHandler
  def handle(response)
    return if office_assigned_by_ccd?(response)

    response.office = OfficeService.lookup_by_case_number(response.case_number)
    response.save
    EventService.publish('ResponseOfficeAssigned', response)
  end

  def office_assigned_by_ccd?(response)
    ExternalSystem.containing_office_code(response.office_code).where(enabled: true, response_remote_office: true, export_responses: true).present?
  end
end
