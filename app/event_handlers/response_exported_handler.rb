class ResponseExportedHandler
  def handle(external_system_id:, response_id:, event_service: Rails.application.event_service)
    export = Export.create! external_system_id: external_system_id, resource_id: response_id, resource_type: 'Response', state: 'created'
    event_service.publish('ResponseQueuedForExport', export)
  end
end
