require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Acas Certificate' do
  explanation "Acas Certificate Resource"

  header "Content-Type", "application/json"
  header "Accept", "application/json"
  header "EtUserId", "my_user"

  before do
    stub_request(:any, /fakeservice\.com/).to_rack(EtFakeAcasServer::Server)
  end

  get '/et_acas_api/certificates/:id' do

    context "200" do
      example 'Valid certificate response' do

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(id: 'R000100/00/14')

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(200)
      end
    end

    context "404" do
      example '404 Error response (certificate not found)' do

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(id: 'R000200/00/14')

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(404)
      end
    end

    context "422" do
      example '422 Error response (certificate format not valid)' do

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(id: 'R000201/00/14')

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(422)
      end
    end

    context "500" do
      example '500 Error response (something wrong with the ACAS server)' do

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(id: 'R000500/00/14')

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(500)
      end
    end
  end
end
