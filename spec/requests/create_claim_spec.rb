# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CreateClaim Request', type: :request do
  # content type "multipart/form-data"
  # body params contain :-
  #   new_claim - Contains the XML data
  #   <filename> - Yes, the filename is the parameter - crazy - it includes the extension as well.  The value is then the file
  #
  # accept application/json
  #
  describe 'POST /api/v1/new-claim' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data'
      }
    end
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    def perform_action
      file_name = 'et1_first_last.pdf'
      uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
      xml_data = File.read(File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user.xml'), __FILE__))
      post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers
    end

    it 'returns the correct status code' do
      # Act - Send some claim data
      perform_action

      # Assert - Make sure we get a 201 - to say the reference number is created
      expect(response).to have_http_status(:created)
    end

    it 'returns status of ok' do
      # Act - Send some claim data
      perform_action

      # Assert - make sure we get status of ok
      expect(json_response).to include status: 'ok'
    end

    it 'returns a reference number which contains 12 digits' do
      # Act - Send some claim data
      perform_action

      # Assert - make sure we get status of ok
      expect(json_response).to include feeGroupReference: a_string_matching(/\A\d{12}\z/)
    end

    it 'returns a valid reference number that is persisted in the database' do
      # Act - Send some claim data
      perform_action
      result = Claim.where(reference: json_response[:feeGroupReference]).first

      # Assert - make sure it is a claim
      expect(result).to be_an_instance_of Claim
    end

    context 'with staging folder visibility' do
      def force_export_now
        ExportClaimsWorker.new.perform
      end

      let(:staging_folder) do
        actions = {
          list_action: lambda {
            get '/atos_api/v1/filetransfer/list'
            response.body
          },
          download_action: lambda { |zip_file|
            get "/atos_api/v1/filetransfer/download/#{zip_file}"
            response
          }

        }
        ETApi::Test::StagingFolder.new actions
      end

      it 'stores the pdf file with the correct filename in the landing folder' do
        # Arrange - Determine what the correct file should be
        correct_file = '222000000300_ET1_First_Last.pdf'

        # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
        perform_action

        # Assert - look for the correct file in the landing folder - will be async
        force_export_now
        expect(staging_folder.all_unzipped_filenames).to include(correct_file)
      end

    end
  end
end
