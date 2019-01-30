require 'active_storage/service/azure_storage_service'
module ActiveStorage
  # Wraps the Microsoft Azure Storage Blob Service as an Active Storage service.
  # See ActiveStorage::Service for the generic API documentation that applies to all services.
  class Service::AzureStorageService < Service
    attr_reader :client, :blobs, :container, :signer

    def initialize(storage_account_name:, storage_access_key:, container:, **client_options)
      @client = Azure::Storage::Client.create(storage_account_name: storage_account_name, storage_access_key: storage_access_key, **client_options)
      @signer = Azure::Storage::Core::Auth::SharedAccessSignature.new(storage_account_name, storage_access_key)
      @blobs = client.blob_client
      @container = container
    end
  end
end
