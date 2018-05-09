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
        ClaimsExportWorker.new.perform
      end

      let(:staging_folder) do
        session = create_session(app)
        actions = {
          list_action: lambda {
            session.get '/atos_api/v1/filetransfer/list'
            session.response.body
          },
          download_action: lambda { |zip_file|
            session.get "/atos_api/v1/filetransfer/download/#{zip_file}"
            session.response
          }
        }
        EtApi::Test::StagingFolder.new actions
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
        perform_action
        force_export_now
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

      it 'should return the reference in the metadata for the response' do
        # Assert - Make sure we get the reference in the metadata
        expect(json_response).to include meta: a_hash_including('BuildResponse' => a_hash_including(reference: instance_of(String)))
      end

      it 'creates a valid txt file in the correct place in the landing folder' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        reference = json_response.dig(:meta, 'BuildResponse', :reference)
        output_filename_txt = "#{reference}_ET3_.txt"
        expect(staging_folder.et3_txt_file(output_filename_txt)).to have_correct_file_structure
      end
    end

    include_context 'with staging folder visibility'

    context 'with json for a response to a non existent claim' do
      include_context 'setup for any response',
        json_factory: -> { FactoryBot.build(:json_build_response_commands) }
      include_examples 'any response variation'
    end

  end
end
