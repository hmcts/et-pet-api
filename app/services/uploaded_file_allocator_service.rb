class UploadedFileAllocatorService
  include Rails.application.routes.url_helpers
  def allocate(filename, into:)
    self.blob = ActiveStorage::Blob.create(filename: filename, byte_size: 0, checksum: 0, metadata: { uploaded: false })
    into.pre_allocated_file_keys.build(filename: filename, key: blob.key)
  end

  def allocated_url
    api_v2_blob_path(signed_id: blob.signed_id(expires_in: 1.hour), filename: blob.filename, host: URI.parse(ActiveStorage::Current.url_options[:host]).host)
  end

  private

  attr_accessor :blob
end
