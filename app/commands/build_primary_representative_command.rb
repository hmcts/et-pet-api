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
    # @TODO (RST-1452) There is no concept of primary representative yet - so it will just add one -
    # therefore this must be first command
    root_object.representatives.build(attributes)
  end
end
