class BuildPrimaryRepresentativeCommand < BaseCommand
  def apply(root_object)
    # @TODO There is no concept of primary respondent yet - so it will just add one - therefore this must be first command
    root_object.representatives.build(input_data)
  end
end
