shared_context 'with cloud provider switching' do |cloud_provider:|
  around do |example|
    original = Rails.configuration.active_storage.service
    begin
      Rails.configuration.active_storage.service = cloud_provider
      ActiveSupport.run_load_hooks(:active_storage_blob, ActiveStorage::Blob)
      example.run
    ensure
      Rails.configuration.active_storage.service = original
      ActiveSupport.run_load_hooks(:active_storage_blob, ActiveStorage::Blob)
    end
  end
end
