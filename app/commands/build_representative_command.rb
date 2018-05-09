class BuildRepresentativeCommand < BaseCommand
  def apply(root_object)
    root_object.build_representative(data)
  end
end
