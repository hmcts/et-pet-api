class CreateClaimFromXmlCommand < BaseCommand
  attribute :xml
  attribute :files

  def apply(root_object, **_args)
    root_object
  end
end
