class ClaimImportMultipleClaimantsHandler
  def handle(claim,
    multiple_claimant_importer_service: ClaimClaimantsFileImporterService)

    multiple_claimant_importer_service.new(claim, autosave: false).call if claim.claimants_csv_file.present?
    claim.save!
    EventService.publish('ClaimMultipleClaimantsImported', claim)
  end
end
