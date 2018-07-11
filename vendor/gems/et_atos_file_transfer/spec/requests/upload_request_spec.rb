require 'rails_helper'
RSpec.describe 'Upload file', type: :request do
  it 'just absorbs the request - does nothing apart from returns a 200' do
    # Act - call the endpoint
    post "/atos_api/v1/filetransfer/upload", params: { filename: 'whoknows' }

    # Assert - make sure we respond correctly
    expect(response).to have_http_status(:ok)
  end
end
