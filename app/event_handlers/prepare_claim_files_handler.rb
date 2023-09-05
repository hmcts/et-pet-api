class PrepareClaimFilesHandler
  def handle(claim)
    ImportUploadedFilesHandler.new.handle(claim)
    ClaimImportMultipleClaimantsHandler.new.handle(claim)
    ConvertFilesHandler.new.handle(claim)
    ClaimPdfFileHandler.new.handle(claim)
    ClaimClaimantsFileHandler.new.handle(claim) if claim.multiple_claimants?
    copy_csv_file(claim: claim)
    claim.save
    claim.events.claim_files_prepared.create
    EventService.publish('ClaimFilesPrepared', claim)
  end

  private

  def copy_csv_file(claim:)
    file = claim.claimants_csv_file
    return if file.nil?

    claimant = claim.primary_claimant
    filename = "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv"
    claim.uploaded_files.system_file_scope.create filename: filename, file: file.file.blob, checksum: file.checksum
  end
end
