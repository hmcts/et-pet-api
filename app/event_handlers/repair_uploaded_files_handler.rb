class RepairUploadedFilesHandler
  def handle(root_object)
    root_object.uploaded_files.includes(:file_attachment).find_each do |uploaded_file|
      next if file_is_ok?(uploaded_file) || (uploaded_file.import_from_key.nil? && uploaded_file.import_file_url.nil?)

      import_from_key(uploaded_file, root_object)
      import_from_url(uploaded_file, root_object)
    end

    root_object.save if root_object.changed?
  end

  private

  def import_from_url(uploaded_file, _root_object)
    UploadedFileImportService.import_file_url(uploaded_file.import_file_url, into: uploaded_file)
  end

  def import_from_key(uploaded_file, root_object)
    UploadedFileImportService.import_from_key(uploaded_file.import_from_key, into: uploaded_file)
  rescue Azure::Core::Http::HTTPError => e
    if e.status_code == 404
      uploaded_file.destroy
      root_object.events.response_repair_file_failed.create data: {
        id: uploaded_file.id,
        filename: uploaded_file.filename,
        reason: 'Externally uploaded file no longer present to import'
      }
    else
      raise e
    end
  end

  def file_is_ok?(uploaded_file)
    uploaded_file.present? && uploaded_file.file.attachment.present?
  end
end
