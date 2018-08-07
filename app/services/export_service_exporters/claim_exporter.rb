module ExportServiceExporters
  class ClaimExporter
    def initialize(claims_to_export: Export.claims.includes(:resource), claim_export_service: ClaimExportService)
      self.claims_to_export = claims_to_export
      self.claim_export_service = claim_export_service
      self.exports = []
    end

    def export(to:)
      claims_to_export.each do |claim_export|
        exports << claim_export
        export_files(claim_export.resource, to: to)
      end
    end

    def mark_claims_as_exported
      # Destroy each individually to
      claims_to_export.where(id: exports.map(&:id)).delete_all
    end

    def exported_count
      exports.length
    end

    private

    def export_files(claim, to:)
      export_file(claim: claim, to: to, prefix: 'ET1', ext: :pdf, type: :pdf)
      export_file(claim: claim, to: to, prefix: 'ET1', ext: :xml, type: :xml)
      export_file(claim: claim, to: to, prefix: 'ET1', ext: :txt, type: :txt)
      export_file(claim: claim, to: to, prefix: 'ET1a', ext: :txt, type: :claimants_txt) if claim.claimants.count > 1
      export_file(claim: claim, to: to, prefix: 'ET1a', ext: :csv, type: :claimants_csv) if claim_has_csv?(claim: claim)
      export_file(claim: claim, to: to, prefix: 'ET1_Attachment', ext: :rtf, type: :rtf) if claim_has_rtf?(claim: claim)
    end

    def export_file(claim:, to:, prefix:, ext:, type:)
      stored_file = claim_export_service.new(claim).send(:"export_#{type}")
      claimant = claim.primary_claimant
      first = replacing_special claimant.first_name
      last = replacing_special claimant.last_name
      fn = "#{claim.reference}_#{prefix}_#{first}_#{last}.#{ext}"
      stored_file.download_blob_to File.join(to, fn)
    end

    def claim_has_csv?(claim:)
      claim.uploaded_files.any? { |f| f.filename.starts_with?('et1a') && f.filename.ends_with?('.csv') }
    end

    def claim_has_rtf?(claim:)
      claim.uploaded_files.any? { |f| f.filename.starts_with?('et1_attachment') && f.filename.ends_with?('.rtf') }
    end

    def replacing_special(text)
      text.gsub(/\s/, '_').gsub(/\W/, '')
    end

    attr_accessor :claim_export_service, :claims_to_export, :exports
  end
end
