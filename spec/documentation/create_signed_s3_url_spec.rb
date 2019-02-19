require 'rails_helper'
require 'rspec_api_documentation/dsl'
resource 'Signed S3 Resource' do
  explanation "Signed S3 resource"

  header "Content-Type", "application/json"
  header "Accept", "application/json"

  # @TODO RST-1676 Remove amazon code
  post '/api/v2/s3/create_signed_url' do

    parameter :uuid, "A unique ID produced by the client to refer to this command", type: :string, with_example: true, in: :body
    parameter :data, "No data is required for this command", with_example: true, in: :body
    parameter :command, type: :string, enum: ['SerialSequence'], with_example: true, in: :body

    context "200" do
      include_context 'with cloud provider switching', cloud_provider: :amazon
      example 'Create a signed s3 object suitable for use in a HTML form for use with direct upload' do
        request =  build(:json_create_signed_s3_url_command).as_json

        # It's also possible to extract types of parameters when you pass data through `do_request` method.
        do_request(request)

        expect(rspec_api_documentation_client.send(:last_response).status).to eq(202)
      end
    end
  end
end
