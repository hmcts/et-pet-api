class BuildRepresentativeCommand < BaseCommand
  attribute :name, :string
  attribute :organisation_name, :string
  attribute :address_attributes, :address_hash, default: {}
  attribute :address_telephone_number, :string
  attribute :mobile_number, :string
  attribute :representative_type, :string
  attribute :dx_number, :string
  attribute :reference, :string
  attribute :contact_preference, :string
  attribute :email_address, :string
  attribute :fax_number, :string

  validates :address_attributes, presence: true, address: true

  def apply(root_object, **_args)
    root_object.build_representative(attributes)
  end
end
