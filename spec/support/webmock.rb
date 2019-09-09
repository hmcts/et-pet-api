require 'webmock/rspec'
other_hosts = [
  'http://azurite:10000'
]
WebMock.disable_net_connect!(allow_localhost: true, allow: other_hosts)
