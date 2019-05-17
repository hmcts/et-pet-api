require 'active_storage/service/azure_storage_service'
RSpec.configure do |c|
  c.before(:suite) do
    ActiveStorage::Blob.service # Ensures that the active storage system is configured
    azure_service = ActiveStorage::Service.configure :azure, Rails.configuration.active_storage.service_configurations
    direct_upload_service = ActiveStorage::Service.configure :azure_direct_upload, Rails.configuration.active_storage.service_configurations
    [azure_service, direct_upload_service].each do |service|
      client = service.blobs
      container_name = service.container
      containers = client.list_containers
      client.create_container(container_name) unless containers.map(&:name).include?(container_name)

      # Empty container
      puts "Emptying container #{container_name}"
      time =Benchmark.ms do
        client.list_blobs(container_name).each do |blob|
          client.delete_blob container_name, blob.name
        end
      end
      puts "Emptied container #{container_name} in #{time}ms"
    end
  end
end
