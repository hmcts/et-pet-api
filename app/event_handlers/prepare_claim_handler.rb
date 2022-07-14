class PrepareClaimHandler
  def handle(claim)
    with_acas_in_background(claim) do
      ImportUploadedFilesHandler.new.handle(claim)
      ClaimImportMultipleClaimantsHandler.new.handle(claim)
      ClaimPdfFileHandler.new.handle(claim)
    end
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

  def with_acas_in_background(claim)
    return yield if claim.primary_respondent.acas_certificate_number.blank?

    downloader = acas_future(claim)
    yield
    certs = downloader.value
    if certs.nil?
      claim.events.claim_acas_requested.create data: { status: 'unknown' }
      return
    end

    certs.each do |cert|
      if cert.is_a?(::EtAcasApi::Certificate)
        uploaded_file = claim.uploaded_files.system_file_scope.build(filename: "acas_#{cert.respondent_name}.pdf")
        uploaded_file.import_base64(cert.certificate_base64, content_type: 'application/pdf')
        claim.updated_at = Time.now.utc
        claim.events.claim_acas_requested.create data: { status: 'found' }
      elsif cert.is_a?(::EtAcasApi::CertificateNotFound)
        claim.events.claim_acas_requested.create data: { status: 'not_found' }
      elsif cert.nil?
        claim.events.claim_acas_requested.create data: { status: 'timeout' }
      else
        claim.events.claim_acas_requested.create data: { status: cert }
      end
    end
  end

  def acas_future(claim, timeout: 60)
    Concurrent::Promises.future(claim) do |claim|
      Timeout.timeout(timeout) do
        respondents = respondents_needing_acas(claim)
        certificates = []
        result = EtAcasApi::QueryService.dispatch(query: 'Certificate', root_object: certificates, ids: respondents.map(&:acas_certificate_number), user_id: 'AutoImporter')
        case result.status
        when :found then
          certificates.each_with_index do |c, idx|
            c.respondent_name = respondents[idx].name
          end
          certificates
        else
          result.status
        end
      end
    end
  end

  def respondents_needing_acas(claim)
    if EtAcasApi::QueryService.supports_multi?
      ([claim.primary_respondent] + claim.secondary_respondents)
    else
      [claim.primary_respondent]
    end
  end
end
