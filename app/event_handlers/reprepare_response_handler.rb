class ReprepareResponseHandler
  def handle(response)
    ActiveRecord::Base.transaction do
      delete_faulty_uploaded_files(response)
      RepairUploadedFilesHandler.new.handle(response)
      unless pdf_file_exists?(response)
        ConvertFilesHandler.new.handle(response)
        ResponsePdfFileHandler.new.handle(response)
        response.events.response_recreated_pdf.create
      end
      response.save if response.changed?
    end
    EventService.publish('ResponsePrepared', response)
    response.events.response_re_prepared.create
  end

  private

  def pdf_file_exists?(response)
    response.uploaded_files.et3_pdf.first.present?
  end

  def uploaded_file_faulty?(uploaded_file)
    return true unless uploaded_file.present? && uploaded_file.file.attachment.present?
    service = uploaded_file.file.service
    !service.exist?( uploaded_file.file.key)
  end

  def delete_faulty_uploaded_files(response)
    response.uploaded_files.each do |uploaded_file|
      next unless !uploaded_file.to_be_imported? && uploaded_file_faulty?(uploaded_file)
      delete_uploaded_file uploaded_file
      response.events.response_deleted_broken_file.create data: { id: uploaded_file.id, filename: uploaded_file.filename }
    end
  end


  def delete_uploaded_file(uploaded_file)
    if uploaded_file.file.attachment.present?
      io = StringIO.new("This file is uploaded only to allow the deletion of the blob to work without error")
      uploaded_file.file.blob.upload(io, identify: false)
      uploaded_file.file.purge
    end
    uploaded_file.destroy
  end
end
