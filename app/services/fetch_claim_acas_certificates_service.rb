class FetchClaimAcasCertificatesService
  def self.call(claim)
    new(claim).call
  end

  def initialize(claim)
    @claim = claim
    @status = :none
    @certificates = []
    @errors = {}
  end

  attr_reader :errors

  def call
    do_fetch
    certificates.each do |cert|
      if cert.is_a?(::EtAcasApi::Certificate)
        build_file(cert, claim)
        claim.touch
        claim.events.claim_acas_requested.create data: { status: 'found' }
      elsif cert.is_a?(::EtAcasApi::CertificateNotFound)
        claim.events.claim_acas_requested.create data: { status: 'not_found' }
      else
        claim.events.claim_acas_requested.create data: { status: 'unknown' }
      end
    end
    claim.save
    self
  end

  def found?
    status == :found
  end

  def not_found?
    status == :not_found
  end

  def not_required?
    status == :not_required
  end

  def acas_server_error?
    status == :acas_server_error
  end

  def invalid?
    errors.present?
  end

  private

  attr_reader :claim, :certificates
  attr_accessor :status

  def build_file(cert, claim)
    uploaded_file = claim.uploaded_files.system_file_scope.build(filename: "acas_#{cert.respondent_name}.pdf")
    uploaded_file.import_base64(cert.certificate_base64, content_type: 'application/pdf')
  end

  def do_fetch
    respondents = self.class.respondents_needing_acas(claim)
    self.status = :not_required and return if respondents.empty?

    result = EtAcasApi::QueryService.dispatch(query: 'Certificate', root_object: certificates, ids: respondents.map(&:acas_certificate_number), user_id: 'AutoImporter')
    self.status = result.status
    errors.merge!(result.errors)
    if result.status == :found
      certificates.each_with_index do |c, idx|
        c.respondent_name = respondents[idx].name
      end
    end
  end

  def self.respondents_needing_acas(claim)
    ([claim.primary_respondent] + claim.secondary_respondents).select { |resp| resp.acas_certificate_number.present? }
  end

end
