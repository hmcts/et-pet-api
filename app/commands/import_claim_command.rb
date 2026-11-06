class ImportClaimCommand < SerialSequenceCommand
  def initialize(uuid:, data:, **args)
    super
  end

  def apply(root_object, meta: {})
    super

    root_object.save!
    EventService.publish('ClaimImported', root_object)
  end
end
