class ClaimCreatedHandler
  def handle(claim, file_builder_service: ClaimFileBuilderService, export_service: ClaimExportService, multiple_claimant_importer_service: ClaimClaimantsFileImporterService)
    multiple_claimant_importer_service.new(claim, autosave: false).call if claim.claimants_csv_file.present?
    file_builder_service.new(claim).call
    rename_csv_file(claim: claim)
    rename_rtf_file(claim: claim)
    claim.save!
    export_service.new(claim).to_be_exported
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
