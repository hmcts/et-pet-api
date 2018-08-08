module ExportServiceExporters
  class ResponseExporter
    def initialize(responses_to_export: Export.responses.includes(:resource),
      response_export_service: ResponseExportService)
      self.responses_to_export = responses_to_export
      self.response_export_service = response_export_service
      self.exports = []
      self.exceptions = []
    end

    def export(to:)
      responses_to_export.each do |response_export|
        with_exception_logging do
          moving_afterwards(to: to) do |tempdir|
            export_files(response_export.resource, to: tempdir)
          end
        end
        exports << response_export
      end
      report_exceptions
    end

    def mark_responses_as_exported
      # Destroy each individually to
      responses_to_export.where(id: exports.map(&:id)).delete_all
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
      text.gsub(/\s/, '_').gsub(/\W/, '')
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

    attr_accessor :response_export_service, :responses_to_export, :exports, :exceptions
  end
end
