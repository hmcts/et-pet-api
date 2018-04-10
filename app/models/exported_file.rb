class ExportedFile < ApplicationRecord
  include StoredFileDownload

  has_one_attached :file

  def file_attributes=(attrs)
    file.attach(attrs)
  end
end
