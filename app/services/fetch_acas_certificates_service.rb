class FetchAcasCertificatesService
  EXPIRY_PERIOD = 1.month # How long the cache entry will last (must be greater than the last retry time)

  # @param [Claim] claim
  def self.call(*args, cache: Rails.cache)
    new(*args).call
  end

  # @private
  def initialize(claim, cache: Rails.cache)
    @claim = claim
    @cache = cache
    @to_remove = []
    @remaining = []
    @existing_file_ids = []
    @max_certificates = 5
  end

  attr_accessor :remaining

  def call
    cached = cache.fetch(cache_key, expires_in: EXPIRY_PERIOD) do
      {
        remaining: [claim.primary_respondent.id] + claim.secondary_respondents.limit(max_certificates - 1).pluck(:id),
        existing_file_ids: claim.uploaded_files.pluck(:id)
      }

    end
    self.remaining = cached[:remaining]
    self.existing_file_ids = cached[:existing_file_ids]
    process remaining
    self
  end

  def success?
    remaining.empty?
  end

  def process(remaining)
    remaining.each do |respondent_id|
      respondent = Respondent.find(respondent_id)
      to_remove << respondent_id and next if file_exists?(respondent)

      cert = certificate_for(respondent)
      if cert.is_a?(::EtAcasApi::Certificate)
        uploaded_file = claim.uploaded_files.system_file_scope.build(filename: "acas_#{respondent.name}.pdf")
        uploaded_file.import_base64(cert.certificate_base64, content_type: 'application/pdf')
        claim.events.claim_acas_requested.build data: { status: 'found' }
        to_remove << respondent_id
      elsif [:invalid_certificate_format, :not_found].include?(cert)
        claim.events.claim_acas_requested.build data: { status: cert }
        to_remove << respondent_id
      else
        claim.events.claim_acas_requested.build data: { status: cert }
      end
    end
  ensure
    claim.save(validate: false)
    remaining.delete_if { |id| to_remove.include?(id) }
  end

  def new_files
    claim.uploaded_files.where.not(id: existing_file_ids)
  end

  private

  def cache_key
    "fetch-acas-cert-for-claim-id-#{claim.id}"
  end

  def certificate_for(respondent)
    certificate_id = respondent.acas_certificate_number
    certificate = ::EtAcasApi::Certificate.new
    result = EtAcasApi::QueryService.dispatch(query: 'Certificate', root_object: certificate, id: certificate_id, user_id: 'AutoImporter')
    case result.status
    when :found then
      certificate
    else
      result.status
    end
  end

  def file_exists?(respondent)
    claim.uploaded_files.where(filename: "acas_#{respondent.name}.pdf").any?
  end

  attr_reader :claim, :to_remove, :cache, :max_certificates
  attr_accessor :existing_file_ids
end
