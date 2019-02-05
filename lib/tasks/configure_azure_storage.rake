require 'azure/storage'

desc "Configure azure storage containers - can be run at any point - but with caution"
task "configure_azure_storage_containers" => :environment do
  options = {
    storage_account_name: ENV.fetch('AZURE_STORAGE_ACCOUNT', 'devstoreaccount1'),
    storage_access_key: ENV.fetch('AZURE_STORAGE_ACCESS_KEY', 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==')
  }
  options[:storage_blob_host] = ENV['AZURE_STORAGE_BLOB_HOST'] if ENV.key?('AZURE_STORAGE_BLOB_HOST')
  options[:use_path_style_uri] = ENV['AZURE_STORAGE_BLOB_FORCE_PATH_STYLE'] == 'true' if ENV.key?('AZURE_STORAGE_BLOB_FORCE_PATH_STYLE')

  direct_upload_client_options = options.merge storage_account_name: ENV.fetch('AZURE_STORAGE_DIRECT_UPLOAD_ACCOUNT', 'devstoreaccount1'),
                                               storage_access_key: ENV.fetch('AZURE_STORAGE_DIRECT_UPLOAD_ACCESS_KEY', 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==')
  client = Azure::Storage.client options
  direct_upload_client = Azure::Storage.client direct_upload_client_options

  container_name = ENV.fetch('AZURE_STORAGE_CONTAINER', 'et-api-container')
  direct_container_name = ENV.fetch('AZURE_STORAGE_DIRECT_UPLOAD_CONTAINER', 'et-api-direct-container')

  containers = client.blob_client.list_containers
  if containers.map(&:name).include?(container_name)
    puts "Azure already has container #{container_name}"
  else
    client.blob_client.create_container(container_name)
    puts "Container #{container_name} added to azure"
  end

  direct_upload_containers = direct_upload_client.blob_client.list_containers
  if direct_upload_containers.map(&:name).include?(direct_container_name)
    puts "Azure already has container #{direct_container_name}"
  else
    direct_upload_client.blob_client.create_container(direct_container_name)
    puts "Container #{direct_container_name} added to azure"
  end
end

desc "Configures cors on the direct upload azure account.  Generally only used in development / test"
task "configure_azure_storage_cors" => :environment do
  options = {
    storage_account_name: ENV.fetch('AZURE_STORAGE_DIRECT_UPLOAD_ACCOUNT', 'devstoreaccount1'),
    storage_access_key: ENV.fetch('AZURE_STORAGE_DIRECT_UPLOAD_ACCESS_KEY', 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==')
  }
  options[:storage_blob_host] = ENV['AZURE_STORAGE_BLOB_HOST'] if ENV.key?('AZURE_STORAGE_BLOB_HOST')
  options[:use_path_style_uri] = ENV['AZURE_STORAGE_BLOB_FORCE_PATH_STYLE'] == 'true' if ENV.key?('AZURE_STORAGE_BLOB_FORCE_PATH_STYLE')
  direct_upload_client = Azure::Storage.client options
  service_properties = direct_upload_client.blob_client.get_service_properties
  if service_properties.cors.cors_rules.empty?
    cors_rule = Azure::Storage::Service::CorsRule.new
    cors_rule.allowed_origins = ['*']
    cors_rule.allowed_methods = %w(POST GET PUT HEAD)
    cors_rule.allowed_headers = ['*']
    cors_rule.exposed_headers = ['*']
    cors_rule.max_age_in_seconds = 3600
    service_properties.cors.cors_rules = [cors_rule]
    direct_upload_client.blob_client.set_service_properties(service_properties)
    puts "Direct upload storage account now has cors configured"
  else
    puts "Direct upload storage account has existing cors config - cowardly refusing to touch it"
  end
end
