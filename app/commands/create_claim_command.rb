class CreateClaimCommand < SerialSequenceCommand
  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: data + extra_commands, **args)
  end

  def apply(root_object, meta: {})
    super
    # This is a bit of a frig - because we are not expecting the caller to
    # add the AssignReferenceToClaim command, we cant expect them to check the meta for
    # that command so we pretend its from the BuildClaim command instead
    meta['BuildClaim'] ||= {}
    meta['BuildClaim'].merge! meta.delete('AssignReferenceToClaim')
    meta['BuildClaim'].merge! meta.delete('PreAllocatePdfFile')

    root_object.save!
    EventService.publish('ClaimCreated', root_object)
  end

  private

  def extra_commands
    [
      { command: 'AssignReferenceToClaim', uuid: SecureRandom.uuid, data: {} },
      { command: 'PreAllocatePdfFile', uuid: SecureRandom.uuid, data: {} }
    ]
  end
end
