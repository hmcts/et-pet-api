def azure_storage_service(service_name)
  ActiveStorage::Blob.services.fetch(service_name)
end

def ensure_azure_storage_container(service_name)
  service = azure_storage_service(service_name)
  return if service.class.name.demodulize == 'DiskService'

  client = service.client
  container_name = service.container

  if client.container_exist?
    puts "Azure already has container #{container_name}"
  else
    client.create_container
    puts "Container #{container_name} added to azure"
  end
end

desc "Configure azure storage containers - can be run at any point - but with caution"
task "configure_azure_storage_containers" => :environment do
  ActiveStorage::Blob.service # Ensures that the active storage system is configured
  service_name = Rails.configuration.active_storage.service

  ensure_azure_storage_container(service_name)
  ensure_azure_storage_container(:"#{service_name}_direct_upload")
end
