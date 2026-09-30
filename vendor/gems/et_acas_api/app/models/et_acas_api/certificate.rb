module EtAcasApi
  class Certificate
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :claimant_name, :string
    attribute :certificate_number, :string
    attribute :message, :string
    attribute :method_of_issue, :string
    attribute :respondent_name, :string
    attribute :date_of_issue, :date
    attribute :date_of_receipt, :date
    attribute :certificate_base64, :string
  end
end
