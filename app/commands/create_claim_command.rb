class CreateClaimCommand < SerialSequenceCommand
  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: data + [{ command: 'AssignReferenceToClaim', uuid: SecureRandom.uuid, data: {} }], **args)
  end

  def apply(root_object, meta: {})
    super
    # This is a bit of a frig - because we are not expecting the caller to
    # add the AssignReferenceToClaim command, we cant expect them to check the meta for
    # that command so we pretend its from the BuildClaim command instead
    meta['BuildClaim'] ||= {}
    meta['BuildClaim'].merge! meta.delete('AssignReferenceToClaim')

    root_object.save!
    EventService.publish('ClaimCreated', root_object)
  end
end
