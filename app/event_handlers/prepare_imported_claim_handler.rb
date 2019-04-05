class PrepareImportedClaimHandler
  def handle(claim)
    ImportUploadedFilesHandler.new.handle(claim)
    ClaimImportMultipleClaimantsHandler.new.handle(claim)
    ClaimPdfFileHandler.new.handle(claim)
    claim.save if claim.changed?
    EventService.publish('ImportedClaimPrepared', claim)
  end
end
