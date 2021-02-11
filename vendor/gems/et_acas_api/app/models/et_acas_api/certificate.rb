module EtAcasApi
  class Certificate
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :claimant_name, :string
    attribute :certificate_number, :string
    attribute :message, :string
    attribute :method_of_issue, :string
    attribute :respondent_name, :string
    attribute :date_of_issue, :datetime
    attribute :date_of_receipt, :datetime
    attribute :certificate_base64, :string
  end
end
