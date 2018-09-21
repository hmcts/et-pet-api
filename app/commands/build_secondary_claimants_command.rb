class BuildSecondaryClaimantsCommand < BaseCommand
  def apply(root_object)
    input_data.each do |data|
      root_object.secondary_claimants.build(data)
    end
  end
end
