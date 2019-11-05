class ResponseExportHandler
  def handle(response)
    ExternalSystem.containing_office_code(response.office_code).where(enabled: true).each do |system|
      if system.always_save_export? || system.export_responses?
        export = Export.responses.create(resource: response, external_system_id: system.id)
        Rails.application.event_service.publish('ResponseQueuedForExport', export) if system.export_responses?
      end

    end

    response.save
  end
end
