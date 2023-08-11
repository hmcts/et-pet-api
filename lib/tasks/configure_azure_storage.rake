require 'azure/storage/blob'

desc "Configure azure storage containers - can be run at any point - but with caution"
task "configure_azure_storage_containers" => :environment do
  ActiveStorage::Blob.service # Ensures that the active storage system is configured
  service = ActiveStorage::Blob.services.fetch(Rails.configuration.active_storage.service)
  next if service.class.name.demodulize == 'DiskService'

  client = service.client
  direct_upload_client = ActiveStorage::Blob.services.fetch(:"#{Rails.configuration.active_storage.service}_direct_upload").client
  container_name = ENV.fetch('AZURE_STORAGE_CONTAINER', 'et-api-container')
  direct_container_name = ENV.fetch('AZURE_STORAGE_DIRECT_UPLOAD_CONTAINER', 'et-api-direct-container')

  containers = client.list_containers
  if containers.map(&:name).include?(container_name)
    puts "Azure already has container #{container_name}"
  else
    client.create_container(container_name)
    puts "Container #{container_name} added to azure"
  end

  direct_upload_containers = direct_upload_client.list_containers
  if direct_upload_containers.map(&:name).include?(direct_container_name)
    puts "Azure already has container #{direct_container_name}"
  else
    direct_upload_client.create_container(direct_container_name)
    puts "Container #{direct_container_name} added to azure"
  end
end

desc "Configures cors on the direct upload azure account.  Generally only used in development / test"
task "configure_azure_storage_cors" => :environment do
  service = ActiveStorage::Blob.services.fetch(:"#{Rails.configuration.active_storage.service}_direct_upload")
  next if service.class.name.demodulize == 'DiskService'

  direct_upload_client = service.client
  service_properties = direct_upload_client.get_service_properties
  if service_properties.cors.cors_rules.empty?
    cors_rule = Azure::Storage::Common::Service::CorsRule.new
    cors_rule.allowed_origins = ['*']
    cors_rule.allowed_methods = ['POST', 'GET', 'PUT', 'HEAD']
    cors_rule.allowed_headers = ['*']
    cors_rule.exposed_headers = ['*']
    cors_rule.max_age_in_seconds = 3600
    service_properties.cors.cors_rules = [cors_rule]
    direct_upload_client.set_service_properties(service_properties)
    puts "Direct upload storage account now has cors configured"
  else
    puts "Direct upload storage account has existing cors config - cowardly refusing to touch it"
  end
end
