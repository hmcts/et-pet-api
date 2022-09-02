# frozen_string_literal: true

class PrepareClaimHandler
  def handle(claim)
    if FetchAcasCertificatesJob.needs_certificates?(claim)
      FetchAcasCertificatesJob.perform_later(claim)
    else
      FetchAcasCertificatesJob.perform_now(claim)
    end
  end
end
