RSpec.configure do |c|
  c.before do
      stub_request(:any, /fakeservice\.com/).to_rack(EtFakeAcasServer::Server)
  end
end
