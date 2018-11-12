class CreateReferenceCommand < BaseCommand
  attribute :post_code, :string

  def apply(root_object, **_args)
    root_object
  end
end
