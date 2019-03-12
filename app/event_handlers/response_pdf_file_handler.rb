class ResponsePdfFileHandler
  def handle(response)
    ResponseFileBuilderService.new(response).call
    response.save!
    Rails.application.event_service.publish('ResponsePdfFileAdded', response)
  end
end
