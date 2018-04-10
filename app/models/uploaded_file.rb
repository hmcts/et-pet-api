class UploadedFile < ApplicationRecord
  has_one_attached :file
  include StoredFileDownload
  def file_attributes=(attrs)
    file.attach(attrs[:file])
  end

end