class BlobCreatedHandler
  def handle(root, file:)
    blob = ActiveStorage::Blob.new key: key, filename: file.original_filename
    build_service_for(blob)
    root[:output_values] ||= {}
    blob.upload(file)
    root[:output_values][:key] = blob.key
  end

  def build_service_for(blob)
    config = Rails.configuration.active_storage
    blob.service_name = :"#{config.service}_direct_upload"
  end

  private

  def key
    "direct_uploads/#{SecureRandom.uuid}"
  end
end
