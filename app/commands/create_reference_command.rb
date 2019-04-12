class CreateReferenceCommand < BaseCommand
  attribute :post_code, :stripped_string

  def apply(root_object, **_args)
    EventService.publish('ReferenceCreated', root_object, command: self)
  end
end
