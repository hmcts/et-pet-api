class ReprepareResponseHandler
  def handle(response)
    ActiveRecord::Base.transaction do
      ImportUploadedFilesHandler.new.handle(response)
      delete_faulty_uploaded_files(response)
      ResponsePdfFileHandler.new.handle(response) unless pdf_file_exists?(response)
      response.save if response.changed?
    end
    EventService.publish('ResponsePrepared', response)
  end

  private

  def pdf_file_exists?(response)
    response.uploaded_files.et3_pdf.first.present?
  end

  def uploaded_file_faulty?(uploaded_file)
    return true unless uploaded_file.present? && uploaded_file.file.attachment.present?
    service = uploaded_file.file.service
    service.blobs.get_blob_properties(service.container, uploaded_file.file.blob.key)
    false
  rescue ::Azure::Core::Http::HTTPError
    true
  end

  def delete_faulty_uploaded_files(response)
    response.uploaded_files.each do |uploaded_file|
      next unless uploaded_file_faulty?(uploaded_file)
      delete_uploaded_file uploaded_file
    end
  end


  def delete_uploaded_file(uploaded_file)
    io = StringIO.new("This file is uploaded only to allow the deletion of the blob to work without error")
    uploaded_file.file.blob.upload(io, identify: false)
    uploaded_file.destroy
  end
end
