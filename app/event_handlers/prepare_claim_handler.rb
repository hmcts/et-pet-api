class PrepareClaimHandler
  def handle(claim)
    with_acas_in_background(claim) do
      ImportUploadedFilesHandler.new.handle(claim)
      ClaimImportMultipleClaimantsHandler.new.handle(claim)
      ClaimPdfFileHandler.new.handle(claim)
    end
    claim.save if claim.changed?
    EventService.publish('ClaimPrepared', claim)
  end

  private

  def with_acas_in_background(claim)
    return yield if claim.primary_respondent.acas_certificate_number.blank?

    downloader = acas_future(claim)
    yield
    cert = downloader.value
    if cert.is_a?(::EtAcasApi::Certificate)
      uploaded_file = claim.uploaded_files.build(filename: "acas_#{claim.primary_respondent.name}.pdf")
      uploaded_file.import_base64(cert.certificate_base64, content_type: 'application/pdf')
      claim.updated_at = Time.now.utc
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
