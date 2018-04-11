# frozen_string_literal: true

# Exported files are received by the ATOS API - they are zip files
# once the ATOS API receives the delete command, is is deleted (or archived)
class ExportedFile < ApplicationRecord
  include StoredFileDownload

  has_one_attached :file

  def file_attributes=(attrs)
    file.attach(attrs)
  end
end
