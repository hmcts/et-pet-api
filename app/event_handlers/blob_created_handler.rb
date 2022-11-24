class BlobCreatedHandler
  def handle(root, uploaded_file:)
    root[:output_values] = {
      key: uploaded_file.key,
      content_type: uploaded_file.content_type,
      filename: uploaded_file.filename
    }
  end
end
