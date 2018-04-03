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

    it 'returns the correct status code' do
      # Act - Send some claim data
      file_name = 'et1_first_last.pdf'
      uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
      xml_data = File.read(File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user.xml'), __FILE__))
      post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers

      # Assert - Make sure we get a 201 - to say the reference number is created
      expect(response).to have_http_status(201)
    end

    it 'returns status of ok' do
      # Act - Send some claim data
      file_name = 'et1_first_last.pdf'
      uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
      xml_data = File.read(File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user.xml'), __FILE__))
      post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers

      # Assert - make sure we get status of ok
      expect(json_response).to include status: 'ok'
    end

    it 'returns a reference number which contains 12 digits' do
      # Act - Send some claim data
      file_name = 'et1_first_last.pdf'
      uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
      xml_data = File.read(File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user.xml'), __FILE__))
      post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers

      # Assert - make sure we get status of ok
      expect(json_response).to include feeGroupReference: a_string_matching(/\A\d{12}\z/)
    end

    it 'returns a valid reference number that is persisted in the database' do
      # Act - Send some claim data
      file_name = 'et1_first_last.pdf'
      uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
      xml_data = File.read(File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user.xml'), __FILE__))
      post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers
      result = Claim.where(reference: json_response[:feeGroupReference]).first

      # Assert - make sure it is a claim
      expect(result).to be_an_instance_of Claim
    end

    context 'looking in landing folder' do
      let(:landing_folder) { Rails.root.join('tmp', 'storage', 'app', 'landing_folder') }
      it 'stores the pdf file with the correct filename in the landing folder' do
        # Arrange - Make sure the file is not already in the landing folder if so delete it
        correct_file = File.join(landing_folder, '222000000300PP_ET1_first_last.pdf')
        File.unlink(correct_file) if File.exist?(correct_file)

        # Act - Send some claim data
        file_name = 'et1_first_last.pdf'
        uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
        xml_data = File.read(File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user.xml'), __FILE__))
        post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers

        # Assert - look for the correct file in the landing folder - will be async

        expect { File.exist?(correct_file) }.to eventually be true
      end

    end
  end
end
