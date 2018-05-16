module ExportServiceExporters
  class ResponseExporter
    def initialize(responses_to_export: Export.responses.includes(:resource),
      response_export_service: ResponseExportService)
      self.responses_to_export = responses_to_export
      self.response_export_service = response_export_service
      self.exports = []
    end

    def export(to:)
      responses_to_export.each do |response_export|
        exports << response_export
        export_files(response_export.resource, to: to)
      end
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
    end

    def export_file(response:, to:, ext:, type:)
      stored_file = response_export_service.new(response).send(:"export_#{type}")
      fn = "#{response.reference}_ET3_.#{ext}"
      stored_file.download_blob_to File.join(to, fn)
    end

    attr_accessor :response_export_service, :responses_to_export, :exports
  end
end
