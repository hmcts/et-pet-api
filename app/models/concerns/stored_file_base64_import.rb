# This module is included in any models that need to be able to import from base 64 into a file stored in
# active storage
#
module StoredFileBase64Import
  extend ActiveSupport::Concern

  def import_base64(base64_data, content_type:)
    file.attach(io: StringIO.new(Base64.decode64(base64_data)), filename: filename, content_type: content_type)
  end
end
