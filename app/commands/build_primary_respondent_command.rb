class BuildPrimaryRespondentCommand < BaseCommand
  attribute :name, :string
  attribute :address_attributes, :address_hash, default: {}
  attribute :work_address_attributes, :address_hash, default: {}
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

  validates :address_attributes, presence: true, address: true
  validates :work_address_attributes, address: { allow_empty: true }
  validates_inclusion_of :acas_exemption_code,
                         in: ['joint_claimant_has_acas_number', 'acas_has_no_jurisdiction',
                                                    'employer_contacted_acas', 'interim_relief'],
                         allow_blank: true
  def apply(root_object, **_args)
    root_object.build_primary_respondent(attributes)
  end
end
