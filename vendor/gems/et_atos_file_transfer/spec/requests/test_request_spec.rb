require 'rails_helper'
RSpec.describe 'Test request endpoint', type: :request do
  it 'responds with a head 200' do
    get '/atos_api/v1/filetransfer/test' do
      expect(response).to have_http_status(:ok)
    end
  end
end
