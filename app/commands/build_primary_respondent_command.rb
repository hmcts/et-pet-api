class BuildPrimaryRespondentCommand < BaseCommand
  attribute :name, :string
  attribute :address_attributes
  attribute :work_address_attributes
  attribute :organisation_more_than_one_site, :boolean
  attribute :contact, :string
  attribute :dx_number, :string
  attribute :address_telephone_number, :string
  attribute :work_address_telephone_number, :string
  attribute :alt_phone_number, :string
  attribute :contact_preference, :string
  attribute :email_address, :string
  attribute :fax_number, :string
  attribute :organisation_employ_gb, :integer
  attribute :employment_at_site_number, :integer
  attribute :disability, :boolean
  attribute :disability_information, :string
  attribute :acas_certificate_number, :string
  attribute :acas_exemption_code, :string

  def apply(root_object, **_args)
    # @TODO (RST-1451) There is no concept of primary respondent yet - so it will just add one -
    # therefore this must be first command
    root_object.respondents.build(attributes)
  end
end
