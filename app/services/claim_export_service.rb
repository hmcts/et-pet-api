# frozen_string_literal: true

# This service is responsible for (but may delegate to others to perform) exporting everything from a claim
class ClaimExportService
  def initialize(claim, claim_exports: ClaimExport)
    self.claim = claim
    self.claim_exports = claim_exports
  end

  def to_be_exported
    claim_exports.create claim: claim
  end

  def export_pdf
    claim.pdf_file
  end

  attr_accessor :claim, :claim_exports
end