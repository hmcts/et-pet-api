require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Claim' do
  explanation "A claim is the claim made by the claimant against the respondent (employer)"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  post '/api/v2/claims/build_claim' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "An array of commands to execute to build the complete claim", with_example: true, in: :body
    parameter :command, type: :string, enum: ['SerialSequence'], with_example: true, in: :body

    context "200" do

      example 'Create a claim with a claimant, respondent and representative with external pdf' do
        request = FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 1, number_of_secondary_respondents: 1, number_of_representatives: 1, has_pdf_file: true).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end

      example 'Create a claim with a claimant, respondent and representative without external pdf' do
        request = FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 1, number_of_secondary_respondents: 1, number_of_representatives: 1, has_pdf_file: false).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end

      example 'Create a claim with a claimant, respondent, representative and claim information file' do
        request = FactoryBot.build(:json_build_claim_commands, :with_rtf_direct_upload, number_of_secondary_claimants: 1, number_of_secondary_respondents: 1, number_of_representatives: 1, has_pdf_file: true).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end
    end
  end
end
