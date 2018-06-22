class DirectUploadIntoCollectionService
  def initialize(collection:, filename:)
    self.collection = collection
    self.filename = filename
  end

  def import(value)
    existing = find_file
    update_or_delete(value, existing) if existing
    create_file(value) unless existing || value.nil?
  end

  private

  def update_or_delete(value, existing = find_file)
    if value.present?
      update_file(value, into: existing)
    else
      delete_file(existing)
    end
  end

  attr_accessor :collection, :filename

  def find_file
    collection.detect { |file| file.filename == filename }
  end

  def create_file(value)
    blob = ActiveStorage::Blob.create!(blob_attributes_for(value))
    import_into_blob(blob, value)
    collection.build(filename: filename, file: blob)
  end

  def update_file(value, into:)
    into.file.update(blob_attributes_for(value))
    blob = into.file.blob
    import_into_blob(blob, value)
  end

  def delete_file(existing = find_file)
    collection.delete(existing)
  end

  def blob_attributes_for(value)
    source_object = s3_client.get_object(bucket: direct_upload_bucket, key: value)
    { filename: filename,
      byte_size: source_object.content_length,
      checksum: 'doesntseemtomatter',
      content_type: 'application/rtf',
      metadata: {} }
  end

  def import_into_blob(blob, value)
    object = blob.service.bucket.object(blob.key)
    object.copy_from(bucket: direct_upload_bucket, key: value)
  end

  def direct_upload_bucket
    @direct_upload_bucket ||= Rails.configuration.s3_direct_upload_bucket
  end

  def s3_client
    @s3_client ||= ActiveStorage::Blob.service.client.client
  end
end
