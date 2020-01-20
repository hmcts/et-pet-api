class BuildBlobCommand < BaseCommand
  def initialize(uuid:, async: true, **_args)
    super(uuid: uuid, data: {}, async: async)
  end

  def apply(root_object, meta:, **_args)
    meta[:cloud_provider] = current_storage
    EventService.publish('BlobBuilt', root_object)
    root_object
  end

  private

  def current_storage
    case ActiveStorage::Blob.service.class.name.demodulize # AzureStorageService, DiskService or S3Service
    when 'AzureStorageService' then 'azure'
    when 'DiskService' then 'local'
    else raise "Unknown storage service in use - #{ActiveStorage::Blob.service.class.name.demodulize}"
    end
  end

end
