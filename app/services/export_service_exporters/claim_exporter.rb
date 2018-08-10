module ExportServiceExporters
  class ClaimExporter
    def initialize(claims_to_export: Export.claims.includes(:resource), claim_export_service: ClaimExportService)
      self.claims_to_export = claims_to_export
      self.claim_export_service = claim_export_service
      self.exports = []
      self.exceptions = []
    end

    def export(to:)
      claims_to_export.each do |claim_export|
        with_exception_logging do
          moving_afterwards(to: to) do |tmpdir|
            export_files(claim_export.resource, to: tmpdir)
          end
          exports << claim_export
        end
      end
      report_exceptions
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
      text.gsub(/\W/, '').parameterize(separator: '_', preserve_case: true)
    end

    def with_exception_logging
      yield
    rescue StandardError => ex
      exceptions << ex
    end

    def report_exceptions
      exceptions.each do |exception|
        Raven.capture_exception(exception)
      end
    end

    def moving_afterwards(to:)
      Dir.mktmpdir do |dir|
        yield dir
        FileUtils.mv(Dir.glob(File.join(dir, '*')), to, force: true)
      end
    end

    attr_accessor :claim_export_service, :claims_to_export, :exports, :exceptions
  end
end
