module ClaimFileBuilder
  module BuildResponseRtfFile
    def self.call(response)
      filename = 'et3_atos_export.rtf'
      original = input_file(response: response)
      return if original.nil?
      response.uploaded_files.build filename: filename,
                                    file: original.file.blob,
                                    checksum: original.checksum
    end

    def self.input_file(response:)
      response.uploaded_files.detect { |u| u.filename == 'additional_information.rtf' }
    end

    private_class_method :input_file
  end
end
