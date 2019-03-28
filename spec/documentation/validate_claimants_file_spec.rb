require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Validate Claimants File' do
  explanation "A service perform validation using various commands"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  post '/api/v2/validate' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "The validation command to perform", with_example: true, in: :body
    parameter :command, type: :string, enum: ['ValidateClaimantsFile'], with_example: true, in: :body

    context "202" do

      example 'Claimants file successfully validated' do
        request = FactoryBot.build(:json_validate_claimants_file_command, :valid).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(200)
      end
    end

    context "400" do
      example "Claimants file invalid - due to invalid rows" do
        request = FactoryBot.build(:json_validate_claimants_file_command, :invalid).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end

      example "Claimants file invalid - due to a missing column" do
        request = FactoryBot.build(:json_validate_claimants_file_command, :missing_column).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end

      example "Claimants file invalid - due to an empty file" do
        request = FactoryBot.build(:json_validate_claimants_file_command, :empty).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end

      example "Claimants file invalid - due to a missing file" do
        request = FactoryBot.build(:json_validate_claimants_file_command, :missing).as_json

        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(400)
      end
    end
  end
end
