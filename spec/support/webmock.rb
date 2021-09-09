require 'webmock/rspec'
other_hosts = [
  'http://azurite:10000',
  ENV.fetch('AZURE_STORAGE_BLOB_HOST', 'http://azure_blob_storage.et.127.0.0.1.nip.io:3100')
]
WebMock.disable_net_connect!(allow_localhost: true, allow: other_hosts)
