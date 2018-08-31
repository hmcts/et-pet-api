class BuildDiversityResponseCommand < BaseCommand
  def apply(root_object)
    root_object.attributes = input_data
  end
end
