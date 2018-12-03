require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Diversity response' do
  explanation "Diversity response resource"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  post '/api/v2/diversity/build_diversity_response' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "The diversity response data", with_example: true, in: :body
    parameter :command, type: :string, enum: ['BuildDiversityResponse'], with_example: true, in: :body

    context "200" do

      example 'Create a diversity response' do
        request = build(:json_build_diversity_response_command, :full).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(201)
      end
    end
  end
end
