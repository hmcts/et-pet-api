module EtAcasApi
  class CertificateNotFound
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :claimant_name, :string
    attribute :certificate_number, :string
    attribute :respondent_name, :string
  end
end
