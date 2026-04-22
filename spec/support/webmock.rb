require 'webmock/rspec'
other_hosts = [
  'http://azurite:10000',
  ENV.fetch('AZURE_STORAGE_BLOB_HOST', 'http://et_azure_blob_storage.localhost:3100')
]
WebMock.disable_net_connect!(allow_localhost: true, allow: other_hosts)
