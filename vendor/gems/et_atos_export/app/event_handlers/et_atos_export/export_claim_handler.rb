module EtAtosExport
  class ExportClaimHandler
    def handle(claim, file_builder_service: EtAtosExport::ClaimFileBuilderService)

      file_builder_service.new(claim).call
      rename_csv_file(claim: claim)
      rename_rtf_file(claim: claim)
      claim.save!
      Rails.application.event_service.publish('ClaimPreparedForAtosExport', claim)
    end

    private

    def rename_csv_file(claim:)
      file = claim.claimants_csv_file
      return if file.nil?
      claimant = claim.primary_claimant
      file.filename = "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv"
    end

    def rename_rtf_file(claim:)
      file = claim.rtf_file
      return if file.nil?
      claimant = claim.primary_claimant
      file.filename = "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.rtf"
    end
  end
end
