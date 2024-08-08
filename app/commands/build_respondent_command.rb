class BuildRespondentCommand < BaseCommand
  attribute :title, :string
  attribute :contact, :string
  attribute :company_number, :string
  attribute :type_of_employer, :string
  attribute :dx_number, :string
  attribute :address_telephone_number, :string
  attribute :work_address_telephone_number, :string
  attribute :alt_phone_number, :string
  attribute :contact_preference, :string
  attribute :email_address, :string
  attribute :organisation_employ_gb, :integer
  attribute :employment_at_site_number, :integer
  attribute :disability, :boolean_with_na
  attribute :disability_information, :string
  attribute :acas_certificate_number, :string
  attribute :acas_exemption_code, :string
  attribute :allow_video_attendance, :boolean, default: false
  attribute :allow_phone_attendance, :boolean, default: false

  attribute :name, :string
  attribute :address_attributes, :address_hash, default: {}
  attribute :work_address_attributes, :address_hash, default: {}
  attribute :organisation_more_than_one_site, :boolean

  validates :address_attributes, presence: true, address: true
  validates :work_address_attributes, address: { allow_empty: true }

  def apply(root_object, **_args)
    root_object.build_respondent(attributes)
  end
end
