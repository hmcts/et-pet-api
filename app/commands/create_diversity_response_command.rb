class CreateDiversityResponseCommand < BaseCommand
  attribute :claim_type, :string
  attribute :sex, :string
  attribute :sexual_identity, :string
  attribute :age_group, :string
  attribute :ethnicity, :string
  attribute :ethnicity_subgroup, :string
  attribute :disability, :string
  attribute :gender, :string
  attribute :gender_at_birth, :string
  attribute :pregnancy, :string
  attribute :religion, :string
  attribute :caring_responsibility, :string
  attribute :relationship, :string

  def apply(root_object, **_args)
    root_object.attributes = attributes
    root_object.save!
    EventService.publish('DiversityResponseCreated', root_object)
  end
end
