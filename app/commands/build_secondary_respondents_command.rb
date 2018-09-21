class BuildSecondaryRespondentsCommand < BaseCommand
  def apply(root_object)
    input_data.each do |data|
      root_object.respondents.build(data)
    end
  end
end
