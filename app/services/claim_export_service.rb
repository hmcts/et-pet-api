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