# frozen_string_literal: true
module EtAtosExport
  # A sidekiq worker which simply delegates its work to ExportService
  # @see ExportService
  class ClaimsExportJob < ApplicationJob
    queue_as :export_claims

    def initialize(*args, claims_export_service: EtAtosExport::ExportService)
      super(*args)
      self.claims_export_service = claims_export_service
    end

    def perform(*)
      ::ExternalSystem.where("reference LIKE '%atos%'").each do |system|
        claims_export_service.new(system: system).export
      end
    end

    private

    attr_accessor :claims_export_service
  end
end
