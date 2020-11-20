module EtAtosExport
  module ExportServiceExporters
    class ClaimExporter
      def initialize(system:, claims_to_export: Export.claims.where(external_system_id: system.id).incomplete.includes(:resource), claim_export_service: ::EtAtosExport::ClaimExportService, events_service: Rails.application.event_service)
        self.claims_to_export = claims_to_export
        self.claim_export_service = claim_export_service
        self.exports = []
        self.exceptions = []
        self.system = system
        self.events_service = events_service
      end

      def export(to:)
        claims_to_export.each do |claim_export|
          with_exception_logging(claim_export) do
            moving_afterwards(to: to) do |tmpdir|
              export_files(claim_export.resource, to: tmpdir)
            end
            exports << claim_export
          end
        end
        report_exceptions
      end

      def mark_claims_as_exported(filename:)
        # Destroy each individually to
        exports.each do |export|
          events_service.publish('ClaimExportedToAtosQueue', export.resource, filename)
        end
        claims_to_export.where(id: exports.map(&:id)).mark_as_complete
      end

      def exported_count
        exports.length
      end

      private

      def export_files(claim, to:)
        export_file(claim: claim, to:
          to, prefix: 'ET1', ext: :pdf, type: :pdf)
        export_file(claim: claim, to: to, prefix: 'ET1', ext: :txt, type: :txt)
        export_file(claim: claim, to: to, prefix: 'ET1a', ext: :txt, type: :claimants_txt) if claim.multiple_claimants?
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
        claim.claimants_csv_file.present?
      end

      def claim_has_rtf?(claim:)
        claim.uploaded_files.any? { |f| f.filename.starts_with?('et1_attachment') && f.filename.ends_with?('.rtf') }
      end

      def replacing_special(text)
        text.gsub(/\W/, '').parameterize(separator: '_', preserve_case: true)
      end

      def with_exception_logging(claim_export)
        yield
      rescue StandardError => ex
        exceptions << [claim_export.id, claim_export.resource_id, ex]
      end

      def report_exceptions
        exceptions.each do |(id, claim_id, exception)|
          Raven.extra_context(export_id: id, claim_id: claim_id) do
            Raven.capture_exception(exception)
          end
        end
      end

      def moving_afterwards(to:)
        Dir.mktmpdir do |dir|
          yield dir
          FileUtils.mv(Dir.glob(File.join(dir, '*')), to, force: true)
        end
      end

      attr_accessor :claim_export_service, :claims_to_export, :exports, :exceptions, :system, :events_service
    end
  end
end
