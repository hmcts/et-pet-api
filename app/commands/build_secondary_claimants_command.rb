class BuildSecondaryClaimantsCommand < BaseCommand
  attribute :secondary_claimants

  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: { secondary_claimants: data }, **args)
  end

  def apply(root_object, **_args)
    secondary_claimants.each do |claimant|
      root_object.secondary_claimants.build(claimant)
    end
  end
end
