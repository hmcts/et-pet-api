# frozen_string_literal: true

# A sidekiq worker which simply delegates its work to ExportService
# @see ExportService
class ClaimsExportJob < ApplicationJob
  queue_as :export_claims

  def initialize(*args, claims_export_service: ExportService.new)
    super(*args)
    self.claims_export_service = claims_export_service
  end

  def perform(*)
    claims_export_service.export
  end

  private

  attr_accessor :claims_export_service
end
