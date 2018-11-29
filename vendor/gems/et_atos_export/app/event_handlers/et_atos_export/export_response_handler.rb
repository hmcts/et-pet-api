module EtAtosExport
  class ExportResponseHandler
    def handle(response)
      EtAtosExport::ResponseFileBuilderService.new(response).call
      response.save!
      Rails.application.event_service.publish('ResponsePreparedForAtosExport', response)
    end
  end
end
