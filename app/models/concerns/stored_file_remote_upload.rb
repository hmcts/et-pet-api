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
    file = Tempfile.new
    file.binmode
    response = HTTParty.get(url, stream_body: true) do |chunk|
      file.write chunk
    end
    file.flush
    self.file = ActionDispatch::Http::UploadedFile.new filename: filename || File.basename(url),
                                                       tempfile: file,
                                                       type: response.content_type
  end

  def import_from_key=(key)
    # @TODO Implement import_from_key - needed for the future
  end
end
