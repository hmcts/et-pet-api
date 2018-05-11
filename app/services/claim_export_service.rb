# frozen_string_literal: true

# This service provides assistance to the ExportService
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
    claim_exports.create resource: claim
  end

  # Exports the pdf file for use by ExportService
  #
  # @return [UploadedFile] The pdf file
  def export_pdf
    claim.pdf_file
  end

  # Exports the xml file for use by ExportService
  #
  # @return [UploadedFile] The xml file
  def export_xml
    claim.uploaded_files.detect { |f| f.filename.ends_with?('.xml') }
  end

  # Exports the text file for use by ExportService
  #
  # @return [UploadedFile] The text file
  def export_txt
    claim.uploaded_files.detect { |f| f.filename.starts_with?('et1_') && f.filename.ends_with?('.txt') }
  end

  # Exports the rtf file for use by ExportService
  #
  # @return [UploadedFile] The rtf file
  def export_rtf
    claim.uploaded_files.detect { |f| f.filename.starts_with?('et1_attachment') && f.filename.ends_with?('.rtf') }
  end

  # Exports the claimants text file for use by ExportService (produces ET1a txt file)
  #
  # @return [UploadedFile] The text file
  def export_claimants_txt
    claim.uploaded_files.detect { |f| f.filename.starts_with?('et1a') && f.filename.ends_with?('.txt') }
  end

  # Exports the claimants csv file for use by ExportService (produces ET1a txt file)
  #
  # @return [UploadedFile] The text file
  def export_claimants_csv
    claim.uploaded_files.detect { |f| f.filename.starts_with?('et1a') && f.filename.ends_with?('.csv') }
  end

  attr_accessor :claim, :claim_exports
end
