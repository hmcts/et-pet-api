class BuildBlobCommand < BaseCommand
  def initialize(uuid:, async: true, **_args)
    super(uuid: uuid, data: {}, async: async)
  end

  def apply(root_object, meta:, **_args)
    meta[:cloud_provider] = Rails.application.config.active_storage.service.to_s
    root_object
  end
end
