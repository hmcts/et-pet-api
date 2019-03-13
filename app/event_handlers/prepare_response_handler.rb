class PrepareResponseHandler
  def handle(response)
    ActiveRecord::Base.transaction do
      ImportUploadedFilesHandler.new.handle(response)
      ResponsePdfFileHandler.new.handle(response)
      ResponseEmailHandler.new.handle(response)
      response.save if response.changed?
      EventService.publish('ResponsePrepared', response)
    end
  end
end
