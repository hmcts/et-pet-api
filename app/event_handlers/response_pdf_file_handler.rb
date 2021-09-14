class ResponsePdfFileHandler
  def handle(response)
    BuildResponsePdfFileService.call(response, template_reference: response.pdf_template_reference, use_xfdf: false)
    response.save!
    Rails.application.event_service.publish('ResponsePdfFileAdded', response)
  end
end
