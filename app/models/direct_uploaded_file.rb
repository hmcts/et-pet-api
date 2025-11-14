class DirectUploadedFile < ApplicationRecord
  include ScannedContentType

  has_one_attached :file, service: :"#{ActiveStorage::Blob.service.name}_direct_upload"

  scan_content_type_for :file

  before_validation :populate_filename

  delegate :key, :content_type, to: :file

  def self.find_by_key!(key)
    joins(:file_blob).find_by!(ActiveStorage::Blob.table_name => { key: key })
  end

  def self.find_by_key(key)
    joins(:file_blob).find_by(ActiveStorage::Blob.table_name => { key: key })
  end

  private

  def populate_filename
    self.filename ||= file.filename.to_s
  end
end
