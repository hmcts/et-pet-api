# frozen_string_literal: true

# This service provides assistance to the ClaimsExportService
# It provides the methods required to get the data that is needed to export
#
class ClaimExportService

  # @param [Claim] claim The claim to export or mark as to be exported
  def initialize(claim, claim_exports: ClaimExport)
    self.claim = claim
    self.claim_exports = claim_exports
  end

  # Marks the claim as available and ready to be exported
  def to_be_exported
    claim_exports.create claim: claim
  end

  # Exports the pdf file for use by ClaimsExportService
  #
  # @return [UploadedFile] The pdf file
  def export_pdf
    claim.pdf_file
  end

  # Exports the xml file for use by ClaimsExportService
  #
  # @return [UploadedFile] The xml file
  def export_xml
    claim.uploaded_files.detect { |f| f.filename.ends_with?('.xml') }
  end

  # Exports the text file for use by ClaimsExportService
  #
  # @return [UploadedFile] The text file
  def export_txt
    claim.uploaded_files.detect { |f| f.filename.ends_with?('.txt') }
  end

  attr_accessor :claim, :claim_exports
end
