class BuildSecondaryRespondentsCommand < BaseCommand
  attribute :secondary_respondents

  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: { secondary_respondents: data }, **args)
  end

  def apply(root_object, **_args)
    secondary_respondents.each do |respondent|
      root_object.respondents.build(respondent)
    end
  end
end
