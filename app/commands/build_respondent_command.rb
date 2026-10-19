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


  validates :disability_information, length: { maximum: 350 }, presence: true, if: :disabled?
  validates :disability, inclusion: { in: ['true', 'false', 'not_applicable', '', nil] }

  validates :name, presence: true
  validates :contact, presence: true, allow_blank: true
  validates :email_address, presence: true, if: :prefer_email?
  validates :organisation_employ_gb, numericality: true, allow_blank: true
  validates :organisation_more_than_one_site, inclusion: { in: [true, false, '', nil] }
  validates :employment_at_site_number, numericality: true, if: :organisation_more_than_one_site
  validates :type_of_employer, inclusion: { in: ['individual', 'limited_company','partnership', 'unincorporated_association', 'other', 'unincorporated_association', '', nil]}
  validates :contact_preference, inclusion: { in: ['email', 'post', '', nil] }

  def apply(root_object, **_args)
    root_object.build_respondent(attributes)
  end

  private

  def disabled?
    disability == 'true'
  end

  def prefer_email?
    contact_preference == "email"
  end
end
