require 'rails_helper'
require 'rspec_api_documentation/dsl'
require 'securerandom'

resource 'Claim Reference' do
  explanation "Claim Reference resource"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  post '/api/v2/references/create_reference' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "The command data containing the post code", with_example: true, in: :body
    parameter :command, type: :string, enum: ['CreateReference'], with_example: true, in: :body

    context "200" do

      example 'Create a reference number based on post code' do
        request = {
          uuid: SecureRandom.uuid,
          command: 'CreateReference',
          async: false,
          data: {
            post_code: 'SW1H 209ST'
          }
        }

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(201)
      end
    end
  end
end
