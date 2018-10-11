class BuildPrimaryClaimantCommand < BaseCommand
  def apply(root_object)
    root_object.build_primary_claimant(input_data)
  end
end
