class ImportClaimCommand < SerialSequenceCommand
  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: data, **args)
  end

  def apply(root_object, meta: {})
    super

    root_object.save!
    EventService.publish('ClaimImported', root_object)
  end
end
