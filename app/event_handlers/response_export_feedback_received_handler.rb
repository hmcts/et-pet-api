class ResponseExportFeedbackReceivedHandler
  def handle(event)
    event_data = JSON.parse(event)
    return unless event_data['state'] == 'complete'

    export = Export.find(event_data['export_id'])
    response = export.resource
    return unless export.external_system.response_remote_office?

    office = Office.find_by(name: event_data.dig('external_data', 'office')) ||
             OfficeService.lookup_by_case_number(response.case_number)
    return unless office && response

    had_office = response.office.present?
    response.office = office
    response.save
    EventService.publish('ResponseOfficeAssigned', response) unless had_office
  end
end
