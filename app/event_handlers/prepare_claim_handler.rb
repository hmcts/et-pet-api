class PrepareClaimHandler
  def handle(claim)
    ImportUploadedFilesHandler.new.handle(claim)
    ClaimImportMultipleClaimantsHandler.new.handle(claim)
    ClaimPdfFileHandler.new.handle(claim)
    claim.save if claim.changed?
    EventService.publish('ClaimPrepared', claim)
  end
end
