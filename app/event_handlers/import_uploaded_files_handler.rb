class ImportUploadedFilesHandler
  def handle(root_object)
    root_object.uploaded_files.includes(:file_attachment).each do |uploaded_file|
      next if uploaded_file.import_from_key.nil? && uploaded_file.import_file_url.nil?

      UploadedFileImportService.import_from_key(uploaded_file.import_from_key, into: uploaded_file)
      UploadedFileImportService.import_file_url(uploaded_file.import_file_url, into: uploaded_file)
    end

    root_object.save if root_object.changed?
  end
end
