RSpec.configure do |c|
  c.before type: :request do
      stub_request(:any, /fakeservice\.com/).to_rack(EtFakeAcasServer::Server)
  end
end
