module EtAtosExport
  module ExportServiceExporters
    class ResponseExporter
      def initialize(system:,
        responses_to_export: Export.responses.incomplete.where(external_system_id: system.id).includes(:resource),
        response_export_service: ResponseExportService, events_service: Rails.application.event_service)
        self.responses_to_export = responses_to_export
        self.response_export_service = response_export_service
        self.exports = []
        self.exceptions = []
        self.system = system
        self.events_service = events_service
      end

      def export(to:)
        responses_to_export.each do |response_export|
          with_exception_logging(response_export) do
            moving_afterwards(to: to) do |tempdir|
              export_files(response_export.resource, to: tempdir)
            end
          end
          exports << response_export
        end
        report_exceptions
      end

      def mark_responses_as_exported(filename:)
        exports.each do |export|
          events_service.publish('ResponseExportedToAtosQueue', export.resource, filename)
        end
        responses_to_export.where(id: exports.map(&:id)).mark_as_complete
      end

      def exported_count
        exports.length
      end

      private

      def export_files(response, to:)
        export_file(response: response, to: to, ext: :txt, type: :txt)
        export_file(response: response, to: to, ext: :pdf, type: :pdf)
        export_file_as_attachment(response: response, to: to, ext: :rtf, type: :rtf, optional: true)
      end

      def export_file(response:, to:, ext:, type:)
        stored_file = response_export_service.new(response).send(:"export_#{type}")
        company_name_underscored = replacing_special response.respondent.name
        fn = "#{response.reference}_ET3_#{company_name_underscored}.#{ext}"
        stored_file.download_blob_to File.join(to, fn)
      end

      def export_file_as_attachment(response:, to:, ext:, type:, optional: false)
        stored_file = response_export_service.new(response).send(:"export_#{type}")
        return if optional && stored_file.nil?
        company_name_underscored = replacing_special response.respondent.name
        fn = "#{response.reference}_ET3_Attachment_#{company_name_underscored}.#{ext}"
        stored_file.download_blob_to File.join(to, fn)
      end

      def replacing_special(text)
        text.gsub(/\s/, '_').gsub(/\W/, '').parameterize(separator: '_', preserve_case: true)
      end

      def with_exception_logging(response_export)
        yield
      rescue StandardError => ex
        [response_export.id, response_export.resource_id, ex]
      end

      def report_exceptions
        exceptions.each do |(id, response_id, exception)|
          Sentry.with_scope do |scope|
            scope.set_extras(export_id: id, response_id: response_id)
            Sentry.capture_exception(exception)
          end
        end
      end

      def moving_afterwards(to:)
        Dir.mktmpdir do |dir|
          yield dir
          FileUtils.mv(Dir.glob(File.join(dir, '*')), to, force: true)
        end
      end

      attr_accessor :response_export_service, :responses_to_export, :exports, :exceptions, :system, :events_service
    end
  end
end
