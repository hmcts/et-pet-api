# frozen_string_literal: true

module EtAtosExport
  # This service provides assistance to the ExportService
  # It provides the methods required to get the data that is needed to export
  #
  class ClaimExportService

    # @param [Claim] claim The claim to export or mark as to be exported
    def initialize(claim, exports: Export.claims)
      self.claim = claim
      self.exports = exports
    end

    # Exports the pdf file for use by ExportService
    #
    # @return [UploadedFile] The pdf file
    def export_pdf
      claim.pdf_file
    end

    # Exports the text file for use by ExportService
    #
    # @return [UploadedFile] The text file
    def export_txt
      claim.uploaded_files.system_file_scope.detect { |f| f.filename.starts_with?('et1_') && f.filename.ends_with?('.txt') }
    end

    # Exports the pdf file for use by ExportService
    #
    # @return [UploadedFile] The claim details file that has been converted to pdf
    def export_claim_details
      claim.uploaded_files.system_file_scope.detect { |f| f.filename.starts_with?('et1_attachment') && f.filename.ends_with?('.pdf') }
    end

    # Exports the claimants text file for use by ExportService (produces ET1a txt file)
    #
    # @return [UploadedFile] The text file
    def export_claimants_txt
      claim.uploaded_files.system_file_scope.detect { |f| f.filename.starts_with?('et1a') && f.filename.ends_with?('.txt') }
    end

    # Exports the claimants csv file for use by ExportService (produces ET1a txt file)
    #
    # @return [UploadedFile] The text file
    def export_claimants_csv
      claim.claimants_csv_file
    end

    attr_accessor :claim, :exports
  end
end
