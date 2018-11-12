class CreateSignedS3FormDataCommand < BaseCommand
  def initialize(uuid:, async: true, **_args)
    super(uuid: uuid, data: {}, async: async)
  end

  def apply(root_object, **_args)
    # This command doesnt do anything to the root object
    root_object
  end
end
