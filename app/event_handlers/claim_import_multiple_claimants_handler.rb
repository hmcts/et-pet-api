class ClaimImportMultipleClaimantsHandler
  def handle(claim,
    multiple_claimant_importer_service: ClaimClaimantsFileImporterService)

    multiple_claimant_importer_service.new(claim, autosave: false).call if claim.claimants_csv_file.present?
    claim.save!
    EventService.publish('ClaimMultipleClaimantsImported', claim)
  end

  private

  def rename_csv_file(claim:)
    file = claim.claimants_csv_file
    return if file.nil?
    claimant = claim.primary_claimant
    file.filename = "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv"
  end

  def rename_rtf_file(claim:)
    file = claim.uploaded_files.detect { |f| f.filename.ends_with?('.rtf') }
    return if file.nil?
    claimant = claim.primary_claimant
    file.filename = "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.rtf"
  end
end
