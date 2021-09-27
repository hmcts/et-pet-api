class PrepareClaimHandler
  def handle(claim)
    with_acas_in_background(claim) do
      ImportUploadedFilesHandler.new.handle(claim)
      ClaimImportMultipleClaimantsHandler.new.handle(claim)
      ClaimPdfFileHandler.new.handle(claim)
    end
    rename_csv_file(claim: claim)
    copy_rtf_file(claim: claim)
    claim.save if claim.changed?
    claim.events.claim_prepared.create
    EventService.publish('ClaimPrepared', claim)
  end

  private

  def rename_csv_file(claim:)
    file = claim.claimants_csv_file
    return if file.nil?
    claimant = claim.primary_claimant
    file.filename = "et1a_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.csv"
    file.save
  end

  def copy_rtf_file(claim:)
    file = claim.rtf_file
    claimant = claim.primary_claimant
    filename = "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.rtf"
    return if file.nil? || output_file_present?(claim: claim, filename: filename)

    claim.uploaded_files.create filename: filename, file: file.file.blob, checksum: file.checksum
  end

  def output_file_present?(claim:, filename:)
    claim.uploaded_files.any? { |u| u.filename == filename }
  end

  def with_acas_in_background(claim)
    return yield if claim.primary_respondent.acas_certificate_number.blank?

    downloader = acas_future(claim)
    yield
    cert = downloader.value
    if cert.is_a?(::EtAcasApi::Certificate)
      uploaded_file = claim.uploaded_files.build(filename: "acas_#{claim.primary_respondent.name}.pdf")
      uploaded_file.import_base64(cert.certificate_base64, content_type: 'application/pdf')
      claim.updated_at = Time.now.utc
      claim.events.claim_acas_requested.create data: { status: 'found' }
    elsif cert.nil?
      claim.events.claim_acas_requested.create data: { status: 'timeout' }
    else
      claim.events.claim_acas_requested.create data: { status: cert }
    end
  end

  def acas_future(claim, timeout: 60)
    Concurrent::Promises.future(claim) do |claim|
      Timeout.timeout(timeout) do
        certificate_id = claim.primary_respondent.acas_certificate_number
        certificate = ::EtAcasApi::Certificate.new
        result = EtAcasApi::QueryService.dispatch(query: 'Certificate', root_object: certificate, id: certificate_id, user_id: 'AutoImporter')
        case result.status
        when :found then
          certificate
        else
          result.status
        end
      end
    end
  end
end
