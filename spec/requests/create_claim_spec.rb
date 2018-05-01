# frozen_string_literal: true

require 'rails_helper'

=begin

1. A single claimant, single respondent and no representative
2. Multiple claimants (not using CSV), single respondent and no representative
3. Multiple claimants (using CSV), single respondent and no representative
4. A single claimant, single respondent and single representative
5. Multiple claimants (not using CSV), single respondent and single representative
6. Multiple claimants (using CSV), multiple respondents and single representative
7. A single claimant, multiple respondents and no representative
8. Multiple claimants (not using CSV), multiple respondents and no representative
9. Multiple claimants (using CSV), multiple respondents and no representative
10. A single claimant, multiple respondents and single representative
11. Multiple claimants (not using CSV), multiple respondents and single representative
12. Multiple claimants (using CSV), multiple respondents and single representative

=end

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

    shared_context 'with staging folder visibility' do
      def force_export_now
        ClaimsExportWorker.new.perform
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

    shared_context 'setup for claims without additional files' do |xml_factory:|
      let(:xml_as_hash) { xml_factory.call }
      let(:xml_input_file) do
        Tempfile.new.tap do |f|
          f.write xml_as_hash.to_xml
          f.rewind
        end
      end
      let(:xml_input_filename) { xml_input_file.path }

      def perform_action
        file_name = 'et1_first_last.pdf'
        uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
        xml_data = File.read(xml_input_filename)
        post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file }, headers: default_headers
      end
    end

    shared_examples 'any claim variation' do
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
        include_context 'with staging folder visibility'
        it 'stores the pdf file with the correct filename in the landing folder' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_First_Last.pdf'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          expect(staging_folder.all_unzipped_filenames).to include(correct_file)
        end

        it 'stores the xml file with the correct filename in the landing folder' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_First_Last.xml'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          expect(staging_folder.all_unzipped_filenames).to include(correct_file)
        end

        it 'stores a copy of the original xml data' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_First_Last.xml'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          Dir.mktmpdir do |dir|
            staging_folder.extract(correct_file, to: File.join(dir, correct_file))
            expect(File.join(dir, correct_file)).to be_an_xml_file_copy_of(xml_input_filename)
          end
        end

        it 'stores a txt file with the correct filename in the landing folder' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_First_Last.txt'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          expect(staging_folder.all_unzipped_filenames).to include(correct_file)
        end
      end
    end


    shared_examples 'validate text file' do |has_representative:, expect_additional_claimants_txt: false|

      context 'with staging folder visibility' do
        include_context 'with staging folder visibility'

        it 'produces the correct txt file contents' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_First_Last.txt'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          Dir.mktmpdir do |dir|
            staging_folder.extract(correct_file, to: File.join(dir, correct_file))
            expect(File.read(File.join(dir, correct_file))).to be_valid_et1_claim_text(multiple_claimants: expect_additional_claimants_txt, representative: has_representative)
          end
        end
      end
    end

    shared_examples 'a claim with single claimant' do
      context 'with staging folder visibility' do
        include_context 'with staging folder visibility'

        it 'does not store an ET1a txt file with the correct filename in the landing folder' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1a_First_Last.txt'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          expect(staging_folder.all_unzipped_filenames).not_to include(correct_file)
        end
      end
    end

    shared_examples 'a claim with multiple claimants' do
      context 'with staging folder visibility' do
        include_context 'with staging folder visibility'

        it 'does not store an ET1a txt file with the correct filename in the landing folder' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1a_First_Last.txt'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          expect(staging_folder.all_unzipped_filenames).to include(correct_file)
        end
      end

    end

    context 'with xml for single claimant and respondent but no representatives' do
      include_context 'setup for claims without additional files',
        xml_factory: -> { FactoryBot.build(:xml_claim, number_of_claimants: 1, number_of_respondents: 1, number_of_representatives: 0) }
      include_examples 'validate text file',
        has_representative: false
      include_examples 'any claim variation'
      include_examples 'a claim with single claimant'
    end

    context 'with xml for multiple claimants, 1 respondent and no representatives' do
      include_context 'setup for claims without additional files',
        xml_factory: -> { FactoryBot.build(:xml_claim, number_of_claimants: 5, number_of_respondents: 1, number_of_representatives: 0) }
      include_examples 'validate text file',
        has_representative: false,
        expect_additional_claimants_txt: true
      include_examples 'any claim variation'
      include_examples 'a claim with multiple claimants'
    end

    context 'with xml for single claimant, respondent and representative' do
      include_context 'setup for claims without additional files',
        xml_factory: -> { FactoryBot.build(:xml_claim, :simple_user) }
      include_examples 'validate text file',
        has_representative: true
      include_examples 'any claim variation'
      include_examples 'a claim with single claimant'
    end

    context 'with xml for multiple claimants, single respondent and representative - with csv file uploaded' do
      let(:xml_as_hash) { build(:xml_claim, :simple_user_with_csv) }
      let(:xml_input_file) do
        Tempfile.new.tap do |f|
          f.write xml_as_hash.to_xml
          f.rewind
        end
      end
      let(:xml_input_filename) { xml_input_file.path }
      let(:csv_file) { File.absolute_path(File.join('..', '..', 'fixtures', "simple_user_with_csv_group_claims.csv"), __FILE__) }

      def perform_action
        file_name = 'et1_first_last.pdf'
        uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
        xml_data = File.read(xml_input_filename)
        post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file, "simple_user_with_csv_group_claims.csv" => fixture_file_upload(csv_file) }, headers: default_headers
      end

      include_examples 'any claim variation'

      context 'with staging folder visibility' do
        include_context 'with staging folder visibility'

        it 'produces the correct txt file contents' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_First_Last.txt'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          Dir.mktmpdir do |dir|
            staging_folder.extract(correct_file, to: File.join(dir, correct_file))
            expect(File.read(File.join(dir, correct_file))).to be_valid_et1_claim_text(multiple_claimants: true)
          end
        end

        it 'stores the csv file' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1a_First_Last.csv'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          Dir.mktmpdir do |dir|
            staging_folder.extract(correct_file, to: File.join(dir, correct_file))
            expect(File.join(dir, correct_file)).to be_a_file_copy_of(csv_file)
          end
        end

        it 'stores an ET1a txt file with the correct filename in the landing folder' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1a_First_Last.txt'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          expect(staging_folder.all_unzipped_filenames).to include(correct_file)
        end
      end
    end

    context 'with xml for single claimant, single respondent and representative - with rtf file uploaded' do
      let(:xml_as_hash) { build(:xml_claim, :simple_user_with_rtf) }
      let(:xml_input_file) do
        Tempfile.new.tap do |f|
          f.write xml_as_hash.to_xml
          f.rewind
        end
      end
      let(:xml_input_filename) { xml_input_file.path }

      let(:rtf_file) { File.absolute_path(File.join('..', '..', 'fixtures', 'simple_user_with_rtf.rtf'), __FILE__) }

      def perform_action
        file_name = 'et1_first_last.pdf'
        uploaded_file = fixture_file_upload(File.absolute_path(File.join('..', '..', 'fixtures', file_name), __FILE__))
        uploaded_rtf_file = fixture_file_upload(rtf_file)
        xml_data = File.read(xml_input_filename)
        post '/api/v1/new-claim', params: { new_claim: xml_data, file_name => uploaded_file, 'simple_user_with_rtf.rtf' => uploaded_rtf_file }, headers: default_headers
      end

      include_examples 'any claim variation'
      context 'with staging folder visibility' do
        include_context 'with staging folder visibility'

        it 'stores the rtf file with the correct filename and is a copy of the original' do
          # Arrange - Determine what the correct file should be
          correct_file = '222000000300_ET1_Attachment_First_Last.rtf'

          # Act - Send some claim data and force the scheduled job through for exporting - else we wont see anything
          perform_action
          force_export_now

          # Assert - look for the correct file in the landing folder - will be async
          Dir.mktmpdir do |dir|
            staging_folder.extract(correct_file, to: File.join(dir, correct_file))
            expect(File.join(dir, correct_file)).to be_a_file_copy_of(rtf_file)
          end
        end
      end
    end
  end
end
