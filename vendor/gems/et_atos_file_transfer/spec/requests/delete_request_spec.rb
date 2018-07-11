require 'rails_helper'
RSpec.describe 'Delete an atos file', type: :request do
  it 'deletes an existing file' do
    # Setup - create 2 files
    files = create_list(:exported_file, 2, :example_zip_file)

    # Act - delete the last one
    post "/atos_api/v1/filetransfer/delete", params: { filename: files.last.filename }

    # Assert - verify that the correct file was deleted
    aggregate_failures 'Verify that the correct one was deleted and the other still exists' do
      expect(EtAtosFileTransfer::ExportedFile.count).to be 1
      expect(EtAtosFileTransfer::ExportedFile.first.filename).to eql files.first.filename
    end
  end

  it 'returns with 204' do
    # Setup - create 2 files
    files = create_list(:exported_file, 2, :example_zip_file)

    # Act - delete the last one
    post "/atos_api/v1/filetransfer/delete", params: { filename: files.last.filename }

    # Assert - make sure we respond correctly
    expect(response).to have_http_status(:no_content)
  end

  it 'return with 404 if the filename does not exist' do
    # Act - delete something that doesnt exists
    post "/atos_api/v1/filetransfer/delete", params: { filename: 'doesntexist' }

    # Assert - make sure we respond correctly
    expect(response).to have_http_status(:not_found)
  end
end
