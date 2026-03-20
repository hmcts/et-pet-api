class DirectUploadedFile < ApplicationRecord
  include ScannedContentType

  has_one_attached :file, service: :"#{ActiveStorage::Blob.service.name}_direct_upload"

  scan_content_type_for :file

  before_validation :populate_filename

  scope :with_blob_key, lambda { |key|
    joins(:file_blob).where(ActiveStorage::Blob.table_name => { key: key })
  }

  delegate :key, :content_type, to: :file

  private

  def populate_filename
    self.filename ||= file.filename.to_s
  end
end
