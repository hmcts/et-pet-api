class Response < ApplicationRecord
  belongs_to :respondent
  belongs_to :representative, optional: true
  has_many :response_uploaded_files, dependent: :destroy
  has_many :uploaded_files, through: :response_uploaded_files

  def additional_information_key=(value)
    existing = ai_file
    if existing
      update_or_remove_ai_file(value, existing)
    else
      create_ai_file(value)
    end
  end

  def has_additional_information_rtf_file?
    ai_file.present?
  end

  private

  def update_or_remove_ai_file(value, existing)
    if value.nil?
      remove_ai_file(existing)
    else
      update_ai_file(value, into: existing)
    end
  end

  def ai_file
    uploaded_files.detect { |file| file.filename == 'additional_information.rtf' }
  end

  def remove_ai_file(existing)
    uploaded_files.delete(existing)
  end

  def create_ai_file(value)
    return if value.nil?
    s3_client = ActiveStorage::Blob.service.client.client
    source_object = s3_client.get_object(bucket: direct_upload_bucket, key: value)
    blob = ActiveStorage::Blob.create!(filename: 'additional_information.rtf',
                                       byte_size: source_object.content_length,
                                       checksum: 'doesntseemtomatter',
                                       content_type: 'application/rtf',
                                       metadata: {})
    object = blob.service.bucket.object(blob.key)
    object.copy_from(bucket: direct_upload_bucket, key: value)
    uploaded_files.build(filename: 'additional_information.rtf', file: blob)
  end

  def update_ai_file(value, into:)
    blob = into.file.blob
    object = blob.service.bucket.object(blob.key)
    object.copy_from(bucket: direct_upload_bucket, key: value)
  end

  def direct_upload_bucket
    @direct_upload_bucket ||= Rails.configuration.s3_direct_upload_bucket
  end
end
