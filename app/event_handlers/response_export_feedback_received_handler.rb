class ResponseExportFeedbackReceivedHandler
  def handle(event)
    event_data = JSON.parse(event)
    return unless event_data['state'] == 'complete'

    export = Export.find(event_data['export_id'])
    response = export.resource
    office = Office.find_by(name: event_data.dig('external_data', 'office'))
    if office && response
      response.office = office
      response.save
    end
  end
end
