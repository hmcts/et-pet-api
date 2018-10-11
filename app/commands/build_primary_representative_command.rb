class BuildPrimaryRepresentativeCommand < BaseCommand
  def apply(root_object)
    # @TODO (RST-1452) There is no concept of primary representative yet - so it will just add one -
    # therefore this must be first command
    root_object.representatives.build(input_data)
  end
end
