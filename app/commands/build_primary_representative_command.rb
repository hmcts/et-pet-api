class BuildPrimaryRepresentativeCommand < BaseCommand
  attribute :name, :string
  attribute :organisation_name, :string
  attribute :address_attributes, default: {}
  attribute :address_telephone_number, :string
  attribute :mobile_number, :string
  attribute :representative_type, :string
  attribute :dx_number, :string
  attribute :reference, :string
  attribute :contact_preference, :string
  attribute :email_address, :string
  attribute :fax_number, :string

  def apply(root_object, **_args)
    root_object.build_primary_representative(attributes)
  end
end
