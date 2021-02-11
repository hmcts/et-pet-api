class UploadedFileAllocatorService
  def allocate(filename, into:)
    self.blob = ActiveStorage::Blob.new(filename: filename, byte_size: 0, checksum: 0)
    into.pre_allocated_file_keys.build(filename: filename, key: blob.key)
  end

  def allocated_url
    blob.url expires_in: 1.hour
  end

  private

  attr_accessor :blob
end
