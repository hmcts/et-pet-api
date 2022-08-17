# frozen_string_literal: true

class FetchAcasCertificatesJob < ApplicationJob
  retry_on
  def perform(claim)
    certs = do_fetch(claim)
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

  private

  def do_fetch(claim)
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

  def respondents_needing_acas(claim)
    [claim.primary_respondent] + claim.secondary_respondents
  end
end
