class PrepareClaimHandler
  def handle(claim)
    ImportUploadedFilesHandler.new.handle(claim)
    ClaimImportMultipleClaimantsHandler.new.handle(claim)
    ClaimPdfFileHandler.new.handle(claim)
    copy_csv_file(claim: claim)
    copy_rtf_file(claim: claim)
    claim.save if claim.changed?
    claim.events.claim_prepared.create
    EventService.publish('ClaimPrepared', claim)
  end

  private

  def copy_csv_file(claim:)
    file = claim.claimants_csv_file
    return if file.nil?
    claimant = claim.primary_claimant
    filename = "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv"
    claim.uploaded_files.system_file_scope.create filename: filename, file: file.file.blob, checksum: file.checksum
  end

  def copy_rtf_file(claim:)
    file = claim.rtf_file
    claimant = claim.primary_claimant
    filename = "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.rtf"
    return if file.nil? || output_file_present?(claim: claim, filename: filename)

    claim.uploaded_files.system_file_scope.create filename: filename, file: file.file.blob, checksum: file.checksum
  end

  def output_file_present?(claim:, filename:)
    claim.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
  end
end
