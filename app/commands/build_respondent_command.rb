class BuildRespondentCommand < BaseCommand
  def apply(root_object)
    root_object.build_respondent(input_data)
  end
end
