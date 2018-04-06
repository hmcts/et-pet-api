require 'rails_helper'
RSpec.describe ClaimExportToLandingService do
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

  describe 'schedule_export' do
    it 'exports the pdf' do
      correct_file = File.join(landing_folder, '222000000300PP_ET1_first_last.pdf')
      File.unlink(correct_file) if File.exist?(correct_file)

      service.schedule_export
      expect { File.exist?(correct_file) }.to eventually be true
    end
  end
end