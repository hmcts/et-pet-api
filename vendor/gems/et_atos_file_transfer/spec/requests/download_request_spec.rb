require 'rails_helper'
RSpec.describe 'Download an atos zip file', type: :request do
  it 'downloads a file' do
    # Arrange - Setup a zip file for downloading
    file_path = File.absolute_path(File.join('..', 'fixtures', 'example_zip_file.zip') ,__dir__)
    zip_file = create(:exported_file, :example_zip_file, file_path: file_path)

    # Act - Download it
    get "/atos_api/v1/filetransfer/download/#{zip_file.filename}"

    # Assert - Check the response - we base64 encode both sides to make comparison easier
    expect(Base64.encode64(response.body)).to eql Base64.encode64(File.read(file_path))
  end

  it 'returns a 404 if a file is not found' do
    # Act - Download wrong filename
    get "/atos_api/v1/filetransfer/download/can-be-anything"

    # Assert - Check the response - we base64 encode both sides to make comparison easier
    expect(response).to have_http_status(:not_found)
  end
end
