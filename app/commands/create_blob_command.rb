class CreateBlobCommand < BaseCommand
  attribute :uploaded_file

  def initialize(uuid:, data:, async: true, **_args)
    super(uuid: uuid, data: data, async: async)
    self.uploaded_file = DirectUploadedFile.new(file: data[:file])
  end

  def apply(root_object, meta:, **_args)
    meta[:cloud_provider] = current_storage
    uploaded_file.save
    EventService.publish('BlobCreated', root_object, uploaded_file: uploaded_file)
    root_object
  end

  delegate :valid?, to: :uploaded_file

  delegate :errors, to: :uploaded_file

  private

  def current_storage
    case ActiveStorage::Blob.service.class.name.demodulize # AzureStorageService, DiskService or S3Service
    when 'AzureStorageService' then 'azure'
    when 'DiskService' then 'local'
    else raise "Unknown storage service in use - #{ActiveStorage::Blob.service.class.name.demodulize}"
    end
  end

end
