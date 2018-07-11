module EtAtosFileTransfer
  class ExportedFile < ApplicationRecord
    self.table_name = :exported_files

    has_one_attached :file

    # Downloads the stored file to the local file system
    #
    # @param [String] filename The filename to download to
    def download_blob_to(filename)
      File.open(filename, 'w') do |output_file|
        output_file.binmode
        file.blob.download { |chunk| output_file.write(chunk) }
        output_file.rewind
      end
    end

    def file_attributes=(attrs)
      file.attach(attrs)
    end
  end
end
