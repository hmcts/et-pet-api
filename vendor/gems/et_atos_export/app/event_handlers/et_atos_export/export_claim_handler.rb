module EtAtosExport
  class ExportClaimHandler
    def handle(claim, file_builder_service: EtAtosExport::ClaimFileBuilderService)

      file_builder_service.new(claim).call
      claim.save!
      Rails.application.event_service.publish('ClaimPreparedForAtosExport', claim)
    end
  end
end
