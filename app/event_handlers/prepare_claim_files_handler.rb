class PrepareClaimFilesHandler
  def handle(claim)
    ImportUploadedFilesHandler.new.handle(claim)
    ClaimImportMultipleClaimantsHandler.new.handle(claim)
    ConvertFilesHandler.new.handle(claim)
    ClaimPdfFileHandler.new.handle(claim)
    copy_csv_file(claim: claim)
    claim.save if claim.changed?
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

  def output_file_present?(claim:, filename:)
    claim.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
  end

  def claim_details_file_name(claim)
    claimant = claim.primary_claimant
    "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}"
  end

end
