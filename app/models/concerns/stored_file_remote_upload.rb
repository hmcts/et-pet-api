require 'net/http'
require 'tempfile'
require 'uri'
# This module is included in any models that need to be able to upload a file from a remote url
#
module StoredFileRemoteUpload
  extend ActiveSupport::Concern

  # Imports a remote file
  #
  # @param [String] url The url of the file to import
  def import_file_url=(url)
    UploadedFileImportService.import_file_url(url, into: self)
  end

  def import_from_key=(key)
    UploadedFileImportService.import_from_key(key, into: self)
  end
end
