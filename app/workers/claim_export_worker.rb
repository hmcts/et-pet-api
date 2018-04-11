# frozen_string_literal: true

# A sidekiq worker which simply delegates its work to ClaimsExportService
# @see ClaimsExportService
class ClaimExportWorker
  include Sidekiq::Worker

  def initialize(claims_export_service: ClaimsExportService.new)
    self.claims_export_service = claims_export_service
  end

  def perform(*)
    claims_export_service.export
  end

  private

  attr_accessor :claims_export_service
end
