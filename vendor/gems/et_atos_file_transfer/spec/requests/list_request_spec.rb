require 'rails_helper'
RSpec.describe 'List all atos files', type: :request do
  it 'lists 2 files' do
    files = create_list(:exported_file, 2, :example_zip_file)
    get '/atos_api/v1/filetransfer/list'
    expect(response.body.lines.map {|l| l.gsub(/\n$/, '')}).to eql files.map(&:filename)
  end
end
