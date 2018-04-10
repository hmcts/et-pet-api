require 'rails_helper'
RSpec.describe ClaimExportService do
  let(:landing_folder) { Rails.root.join('tmp', 'storage', 'app', 'landing_folder') }
  let(:pdf_file_attributes) do
    {
      file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf') ,
      filename: 'et1_first_last.pdf',
      checksum: 'ee2714b8b731a8c1e95dffaa33f89728'
    }
  end
  let(:claim) { create(:claim, :with_pdf_file) }
  subject(:service) { described_class.new(claim) }

  describe 'to_be_exported' do
    it 'marks the claim as ready to be exported' do
      expect { service.to_be_exported }.to change(ClaimExport, :count).by(1)
    end
  end
end