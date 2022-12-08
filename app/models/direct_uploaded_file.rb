class DirectUploadedFile < ApplicationRecord
  include ScannedContentType

  has_one_attached :file, service: :"#{ActiveStorage::Blob.service.name}_direct_upload"

  validates :file, file_content_type: true

  scan_content_type_for :file

  before_validation :populate_filename

  delegate :key, :content_type, to: :file

  private

  def populate_filename
    self.filename ||= file.filename.to_s
  end
end
