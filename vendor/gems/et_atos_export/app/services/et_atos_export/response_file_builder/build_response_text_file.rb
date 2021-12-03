module EtAtosExport
  module ResponseFileBuilder
    module BuildResponseTextFile
      include RenderToFile
      def self.call(response)
        filename = 'et3_atos_export.txt'
        return if output_file_present?(response: response, filename: filename)
        response.uploaded_files.system_file_scope.build filename: filename,
                                                        file: raw_text_file(filename, response: response)
      end

      def self.raw_text_file(filename, response:)
        ActionDispatch::Http::UploadedFile.new filename: filename,
                                               tempfile: render_to_file(object: response),
                                               type: 'text/plain'
      end

      def self.render(response)
        ApplicationController.render "et_atos_export/file_builders/export_response",
                                     locals:  {
                                       response:       response,
                                       respondent:     response.respondent,
                                       representative: response.representative,
                                       office:         office_for(response)
                                     },
                                     formats: [:txt]
      end

      def self.office_for(response, office_service: OfficeService)
        office_service.lookup_by_case_number(response.case_number)
      end

      def self.output_file_present?(response:, filename:)
        response.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
      end

      private_class_method :raw_text_file, :render, :office_for
      private_class_method :output_file_present?
    end
  end
end
