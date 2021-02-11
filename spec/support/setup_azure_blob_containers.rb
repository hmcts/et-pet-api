require 'active_storage/service/azure_storage_service'
RSpec.configure do |c|
  c.before(:suite) do
    ActiveStorage::Blob.service # Ensures that the active storage system is configured
    azure_service = ActiveStorage::Blob.services.fetch(:azure_test)
    direct_upload_service = ActiveStorage::Blob.services.fetch(:azure_test_direct_upload)
    [azure_service, direct_upload_service].each do |service|
      client = service.client
      container_name = service.container
      containers = client.list_containers
      client.delete_container(container_name) if containers.map(&:name).include?(container_name)
      Timeout.timeout 30 do
        loop do
          client.create_container(container_name)
          break
        rescue Azure::Core::Http::HTTPError => ex
          raise unless ex.status_code == 409

          sleep 1
        end
      end
    end
  end
end
