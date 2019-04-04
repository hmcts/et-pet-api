class PrepareResponseHandler
  def handle(response)
    ActiveRecord::Base.transaction do
      ImportUploadedFilesHandler.new.handle(response)
      ResponsePdfFileHandler.new.handle(response)
      response.save if response.changed?
    end
    EventService.publish('ResponsePrepared', response)
  end
end
