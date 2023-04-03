module EtAtosExport
  module ResponseFileBuilder
    module BuildResponseRtfFile
      def self.call(response)
        filename = 'et3_atos_export_additional_information.pdf'
        original = input_file(response: response)
        return if original.nil? || output_file_present?(response: response, filename: filename)
        response.uploaded_files.system_file_scope.build filename: filename,
          file: original.file.blob,
          checksum: original.checksum
      end

      def self.input_file(response:)
        response.uploaded_files.system_file_scope.detect { |u| u.filename == 'additional_information.pdf' }
      end

      def self.output_file_present?(response:, filename:)
        response.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
      end

      private_class_method :input_file
      private_class_method :output_file_present?
    end
  end
end
