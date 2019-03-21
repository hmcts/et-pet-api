class BuildPrimaryClaimantCommand < BaseCommand
  attribute :title, :string
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :address_attributes, :address_hash, default: {}
  attribute :address_telephone_number, :string
  attribute :mobile_number, :string
  attribute :email_address, :string
  attribute :fax_number, :string
  attribute :contact_preference, :string
  attribute :gender, :string
  attribute :date_of_birth, :date
  attribute :special_needs, :string

  validates :address_attributes, presence: true, address: true
  validates :contact_preference, inclusion: { in: ['Email', 'Post', 'Fax'] }

  def apply(root_object, **_args)
    root_object.build_primary_claimant(attributes)
  end
end
