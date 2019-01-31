require 'active_storage/service/s3_service'
RSpec.configure do |c|
  c.before(:suite) do
    next unless ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::AzureStorageService)
    client = ActiveStorage::Blob.service.blobs
    container_name = ActiveStorage::Blob.service.container
    containers = client.list_containers
    next if containers.map(&:name).include?(container_name)

    client.create_container(container_name)
  end
end
