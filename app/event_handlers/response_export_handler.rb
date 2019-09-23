class ResponseExportHandler
  def handle(response)
    ExternalSystem.containing_office_code(response.office_code).where(enabled: true, export_responses: true).each do |system|
      export = Export.responses.create resource: response, external_system_id: system.id
      Rails.application.event_service.publish('ResponseQueuedForExport', export)
    end

    response.save
  end
end
