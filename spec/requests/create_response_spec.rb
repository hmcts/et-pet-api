# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create Response Request', type: :request do
  describe 'POST /api/v2/respondents/build_response' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    shared_context 'with staging folder visibility' do
      def force_export_now
        ResponsesExportWorker.new.perform
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
    end

    shared_context 'setup for any response' do |json_factory:|
      let(:input_factory) { json_factory.call }
      let(:output_files_generated) { [] }

      def perform_action
        json_data = input_factory.to_json
        post '/api/v2/respondents/build_response', params: json_data, headers: default_headers
      end

      before do
        new_files = staging_folder.tracking_new_files do
          perform_action
          force_export_now
        end
        output_files_generated.concat new_files
      end
    end

    shared_examples 'any response variation' do
      it 'should respond with a 201 status' do
        # Assert - Make sure we get a 201 - to say the commands have been accepted
        expect(response).to have_http_status(:accepted)
      end

      it 'should return the uuid as a reference to what will be created' do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'accepted', uuid: input_factory.uuid
      end

      it 'creates a valid txt file in the correct place in the landing folder' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        expect(staging_folder.et3_txt_file_from_zips(output_files_generated)).to have_correct_file_structure
      end
    end

    include_context 'with staging folder visibility'
    context 'with json for a response to a non existent claim' do
      include_context 'setup for any response',
        json_factory: -> { build(:json_build_response_commands) }
      include_examples 'any response variation'
    end

  end
end
