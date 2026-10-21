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
  attribute :allow_video_attendance, :boolean, default: false
  attribute :allow_phone_attendance, :boolean, default: false

  validates :address_attributes, presence: true, address: true
  validates :representative_type,
            inclusion: {
              in: [
                "Citizens Advice Bureau",
                "CAB",
                "FRU",
                "Free Representation Unit",
                "Law Centre",
                "Union",
                "Solicitor",
                "Private Individual",
                "Trade Association",
                "Other",
                "",
                nil
              ]
            }

  validates :contact_preference, inclusion: { in: ['email', 'post', '', nil] }
  validates :email_address, presence: true, if: :email_contact_preference

  def apply(root_object, **_args)
    root_object.build_representative(attributes)
  end

  def email_contact_preference
    contact_preference == 'email'
  end
end
