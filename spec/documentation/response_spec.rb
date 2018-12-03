require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Response' do
  explanation "A response is the response from the employer who the claim is made against.  It comes from the ET3 form"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  post '/api/v2/respondents/build_response' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "An array of commands to build the response and its various components", with_example: true, in: :body
    parameter :command, type: :string, enum: ['SerialSequence'], with_example: true, in: :body

    context "202" do

      example 'Response successfully created' do
        request = FactoryBot.build(:json_build_response_commands, :with_representative).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end
    end

    context "400" do
      example "Response not created - this example shows invalid case number due to the office code not being correct" do
        request = FactoryBot.build(:json_build_response_commands, :invalid_case_number).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end
    end
  end
end
