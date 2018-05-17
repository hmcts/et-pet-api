class ResponseCreatedHandler
  def handle(response)
    ResponseFileBuilderService.new(response).call
    ResponseExportService.new(response).to_be_exported
    response.save
  end
end
