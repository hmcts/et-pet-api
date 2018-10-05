class BuildPrimaryRespondentCommand < BaseCommand
  def apply(root_object)
    # @TODO (RST-1451) There is no concept of primary respondent yet - so it will just add one -
    # therefore this must be first command
    root_object.respondents.build(input_data)
  end
end
