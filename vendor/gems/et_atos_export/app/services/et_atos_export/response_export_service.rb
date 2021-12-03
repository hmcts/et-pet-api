# frozen_string_literal: true

module EtAtosExport
  # This service provides assistance to the ExportService
  # It provides the methods required to get the data that is needed to export the response
  #
  class ResponseExportService

    # @param [Response] response The response to export or mark as to be exported
    def initialize(response, exports: Export)
      self.response = response
      self.exports = exports
    end

    # Exports the pdf file for use by ExportService
    #
    # @return [UploadedFile] The pdf file
    def export_pdf
      response.pdf_file
    end

    # Exports the text file for use by ExportService
    #
    # @return [UploadedFile] The text file
    def export_txt
      response.uploaded_files.system_file_scope.detect { |f| f.filename == 'et3_atos_export.txt' }
    end

    # Exports the rtf file for use by ExportService
    #
    # @return [UploadedFile] The rtf file
    def export_rtf
      response.uploaded_files.system_file_scope.detect { |f| f.filename == 'et3_atos_export.rtf' }
    end

    attr_accessor :response, :exports
  end
end
