class ResponseExportHandler
  def handle(response)
    ExternalSystem.containing_office_code(response.office_code).each do |system|
      Export.responses.create resource: response, external_system_id: system.id
    end

    response.save
  end
end
