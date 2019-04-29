# frozen_string_literal: true

# @TODO RST-1729 - Remove all url based tests for the input files (rtf and csv) - they have their tests duplicated
#  using the direct upload method - but we couldnt remove until the old url method has stopped being used.
require 'rails_helper'
RSpec.describe 'Create Claim Request', type: :request do
  describe 'POST /api/v2/claims/build_claim' do
    let(:default_headers) do
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    shared_context 'with fake sidekiq' do
      around do |example|
        begin
          original_adapter = ActiveJob::Base.queue_adapter
          ActiveJob::Base.queue_adapter = :test
          ActiveJob::Base.queue_adapter.enqueued_jobs.clear
          ActiveJob::Base.queue_adapter.performed_jobs.clear
          example.run
        ensure
          ActiveJob::Base.queue_adapter = original_adapter
        end
      end

      def run_background_jobs
        previous_value = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
        ActiveJob::Base.queue_adapter.enqueued_jobs.select { |j| j[:job] == EventJob }.each do |job|
          job[:job].perform_now(*ActiveJob::Arguments.deserialize(job[:args]))
        end
      ensure
        ActiveJob::Base.queue_adapter.perform_enqueued_jobs = previous_value
      end
    end

    shared_context 'with background jobs running' do
      before do |example|
        next if example.metadata[:background_jobs] == :disable

        run_background_jobs
        force_export_now
      end
    end

    shared_context 'with setup for claims' do |json_factory:|
      let(:input_factory) { json_factory.call }

      before do
        stub_request(:any, /mocked_atos_server\.com/).to_rack(EtAtosFileTransfer::Engine)
      end

      let(:staging_folder) do
        EtApi::Test::StagingFolder.new url: 'http://mocked_atos_server.com',
                                       username: 'atos',
                                       password: 'password'
      end

      let(:secondary_staging_folder) do
        EtApi::Test::StagingFolder.new url: 'http://mocked_atos_server.com',
                                       username: 'atos2',
                                       password: 'password'
      end

      # A private scrubber to set expectations for the filename - replaces white space with underscores and any non word chars are removed
      scrubber = ->(text) { text.gsub(/\s/, '_').gsub(/\W/, '') }

      let(:input_primary_claimant_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryClaimant' }.data }
      let(:input_secondary_claimants_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildSecondaryClaimants' }.data }
      let(:input_primary_respondent_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRespondent' }.data }
      let(:input_secondary_respondents_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildSecondaryRespondents' }.data }
      let(:input_primary_representative_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRepresentative' }.try(:data) }
      let(:input_claim_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaim' }.data }
      let(:output_reference) { json_response.dig('meta', 'BuildClaim', 'reference') }
      let(:output_filename_pdf) { "#{output_reference}_ET1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.pdf" }
      let(:output_filename_txt) { "#{output_reference}_ET1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.txt" }
      let(:output_filename_rtf) { "#{output_reference}_ET1_Attachment_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.rtf" }
      let(:output_filename_additional_claimants_txt) { "#{output_reference}_ET1a_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.txt" }
      let(:output_filename_additional_claimants_csv) { "#{output_reference}_ET1a_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.csv" }

      before do
        perform_action
      end

      def perform_action
        json_data = input_factory.to_json
        post '/api/v2/claims/build_claim', params: json_data, headers: default_headers
      end

      def force_export_now
        EtAtosExport::ClaimsExportJob.perform_now
      end
    end

    shared_examples 'any claim variation' do
      it 'returns the correct status code', background_jobs: :disable do
        # Assert - Make sure we get a 202 - to say the claim has been accepted and a reference number is created
        expect(response).to have_http_status(:accepted)
      end

      it 'returns status of ok', background_jobs: :disable do
        # Assert - make sure we get status of accepted
        expect(json_response).to include status: 'accepted'
      end

      it 'returns a reference number which contains 12 digits', background_jobs: :disable do
        # Assert - make sure we get status of ok
        expect(json_response.dig('meta', 'BuildClaim')).to include reference: a_string_matching(/\A\d{12}\z/)
      end

      it 'returns a valid reference number that is persisted in the database', background_jobs: :disable do
        result = Claim.where(reference: json_response.dig('meta', 'BuildClaim', 'reference')).first

        # Assert - make sure it is a claim
        expect(result).to be_an_instance_of Claim
      end

      it 'returns the correct office data structure' do
        # Assert - make sure the office data is correct
        office = json_response.dig('meta', 'BuildClaim', 'office').symbolize_keys
        expect(office).to include code: instance_of(Integer),
                                  name: instance_of(String),
                                  telephone: instance_of(String),
                                  address: instance_of(String),
                                  email: instance_of(String)
      end

      it 'returns exactly the same data if called twice with the same uuid', background_jobs: :disable do
        # Arrange - get the response from the first call and reset the session ready for the second
        response1 = JSON.parse(response.body).with_indifferent_access
        reset!

        # Act - Make the call a second time
        perform_action
        response2 = JSON.parse(response.body).with_indifferent_access

        # Assert - Make sure its identical
        expect(response1).to eq response2
      end

      it 'does not create another claim if called for a second time with same uuid', background_jobs: :disable do

        # Assert
        expect { perform_action }.not_to change(Claim, :count)
      end
    end

    shared_examples 'any bad request error variation' do
      it 'responds with a 400 status', background_jobs: :disable do
        # Assert - Make sure we get a 400 - to say the commands have not been accepted
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the status  as not accepted', background_jobs: :disable do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'not_accepted', uuid: input_factory.uuid
      end
    end

    shared_examples 'a claim exported to primary ATOS' do
      it 'stores the pdf file with the correct filename in the landing folder' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.all_unzipped_filenames).to include(output_filename_pdf)
      end

      it 'has the correct structure in the et1 txt file' do
        # Assert - look for the correct structure
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_correct_file_structure(errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary claimant in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        #
        claimant = normalize_json_claimant(input_primary_claimant_factory.to_h)
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_claimant_for(claimant, errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary respondent in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        respondent = normalize_json_respondent(input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRespondent' }.data.to_h)
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_respondent_for(respondent, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim exported to secondary ATOS' do
      it 'stores the pdf file with the correct filename in the landing folder' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(secondary_staging_folder.all_unzipped_filenames).to include(output_filename_pdf)
      end

      it 'has the correct structure in the et1 txt file' do
        # Assert - look for the correct structure
        expect(secondary_staging_folder.et1_txt_file(output_filename_txt)).to have_correct_file_structure(errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary claimant in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        #
        claimant = normalize_json_claimant(input_primary_claimant_factory.to_h)
        expect(secondary_staging_folder.et1_txt_file(output_filename_txt)).to have_claimant_for(claimant, errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary respondent in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        respondent = normalize_json_respondent(input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRespondent' }.data.to_h)
        expect(secondary_staging_folder.et1_txt_file(output_filename_txt)).to have_respondent_for(respondent, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with provided reference number' do
      it 'returns a reference number which matches the one provided if one was provided', background_jobs: :disable do
        # Assert - make sure we get status of ok
        claim = normalize_json_claim(input_claim_factory.to_h)
        expect(json_response.dig('meta', 'BuildClaim')).to include reference: claim[:reference]
      end
    end

    shared_examples 'a claim with single respondent' do
      it 'has no secondary respondents in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_no_additional_respondents(errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with multiple respondents' do
      it 'has the secondary respondents in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        respondents = normalize_json_respondents(input_secondary_respondents_factory.map(&:to_h))
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_additional_respondents_for(respondents, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with single claimant' do
      it 'states that no additional claimants have been sent in the txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_no_additional_claimants_sent(errors: errors), -> { errors.join("\n") }
      end

      it 'does not store an ET1a txt file with the correct filename in the landing folder' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.all_unzipped_filenames).not_to include(output_filename_additional_claimants_txt)
      end
    end

    shared_examples 'a claim with multiple claimants' do
      it 'states that additional claimants have been sent in the txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_additional_claimants_sent(errors: errors), -> { errors.join("\n") }
      end

      it 'stores an ET1a txt file with the correct structure' do
        expect(staging_folder.et1a_txt_file(output_filename_additional_claimants_txt)).to have_correct_file_structure(errors: errors), -> { errors.join("\n") }
      end

      it 'stores an ET1a txt file with the correct header for the given input data' do
        claim = normalize_json_claim(input_claim_factory.to_h)
        claimant = normalize_json_claimant(input_primary_claimant_factory.to_h)
        respondent = normalize_json_respondent(input_primary_respondent_factory.to_h)
        expect(staging_folder.et1a_txt_file(output_filename_additional_claimants_txt)).to have_header_for(claim, primary_claimant: claimant, primary_respondent: respondent, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with multiple claimants from json' do
      it 'stores an ET1a txt file with all of the claimants in the correct format' do
        # Assert
        claimants = normalize_json_claimants(input_secondary_claimants_factory.map(&:to_h))
        expect(staging_folder.et1a_txt_file(output_filename_additional_claimants_txt)).to have_claimants_for(claimants, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with multiple claimants from csv' do
      it 'stores an ET1a txt file with all of the claimants in the correct format' do
        # Assert
        claimants = normalize_claimants_from_file
        expect(staging_folder.et1a_txt_file(output_filename_additional_claimants_txt)).to have_claimants_for(claimants, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with no representatives' do
      it 'has no representative in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_no_representative(errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with a representative' do
      it 'has the representative in the et1 txt file' do
        # Assert - look for the correct file in the landing folder - will be async
        rep = normalize_json_representative(input_primary_representative_factory.to_h)
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_representative_for(rep, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim with a csv file' do
      let(:input_csv_file) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimantsFile' }.data.filename }

      it 'stores the csv file' do
        # Assert - look for the correct file in the landing folder - will be async
        Dir.mktmpdir do |dir|
          staging_folder.extract(output_filename_additional_claimants_csv, to: File.join(dir, output_filename_additional_claimants_csv))
          input_csv_file_full_path = File.absolute_path(File.join('..', '..', '..', 'fixtures', input_csv_file), __FILE__)
          expect(File.join(dir, output_filename_additional_claimants_csv)).to be_a_file_copy_of(input_csv_file_full_path.downcase)
        end
      end
    end

    shared_examples 'a claim with an rtf file' do
      let(:input_rtf_file) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimDetailsFile' }.data.filename }

      it 'stores the rtf file with the correct filename and is a copy of the original' do
        # Assert - look for the correct file in the landing folder - will be async
        Dir.mktmpdir do |dir|
          staging_folder.extract(output_filename_rtf, to: File.join(dir, output_filename_rtf))
          input_rtf_file_full_path = File.absolute_path(File.join('..', '..', '..', 'fixtures', input_rtf_file.downcase), __FILE__)
          expect(File.join(dir, output_filename_rtf)).to be_a_file_copy_of(input_rtf_file_full_path)
        end
      end
    end

    # @TODO RST-1741 - Once we only generating pdf's internally for et1 - the examples in here can be merged with the normal output folder shared examples
    shared_examples 'a claim exported to primary ATOS with internally generated pdf' do
      it 'returns the expected pdf url which will return 404 when fetched before background jobs run', background_jobs: :disable do
        # Assert - Make sure we get the pdf url in the metadata and it returns a 404 when accessed
        url = json_response.dig(:meta, 'BuildClaim', 'pdf_url')
        res = HTTParty.get(url)
        expect(res.code).to be 404
      end

      it 'returns the actual pdf url which should be accessible after the background jobs have run' do
        # Assert - Make sure we get the pdf url in the metadata and it returns a 404 when accessed
        url = json_response.dig(:meta, 'BuildClaim', 'pdf_url')
        res = HTTParty.get(url)
        expect(res.code).to be 200
      end

      it 'creates a valid pdf file the data filled in correctly' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        expect(staging_folder.et1_pdf_file(output_filename_pdf, template: input_claim_factory.pdf_template_reference)).to have_correct_contents_for(
          claim: input_claim_factory,
          claimants: [input_primary_claimant_factory] + input_secondary_claimants_factory,
          respondents: [input_primary_respondent_factory] + input_secondary_respondents_factory,
          representative: input_primary_representative_factory
        )
      end
    end

    context 'with json for single claimant and respondent, no representatives, no reference number and an external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent, no representatives and no reference number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent (with no work address), no representatives, no reference number and an external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, primary_respondent_traits: [:full, :no_work_address], has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent (with no work address), no representatives, no reference number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, primary_respondent_traits: [:full, :no_work_address], has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent, no representatives and an external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimants, 1 respondent, no representatives and an external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimants, 1 respondent and no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    # @TODO RST-1741 - When we are only using internally generated pdf's - all of the examples in this block must have their has_pdf_file set to false
    # @TODO RST-1676 - The amazon context can be removed and the shared examples expanded back into the only context using them
    context 'with json involving external files' do
      shared_examples 'all file examples' do
        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using url but uppercased filename' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_uppercased, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using direct upload but uppercased filename' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload_uppercased, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and representative - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and representative - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents but no representatives - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents but no representatives - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents and a representative - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents and a representative - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with multiple claimants'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf_direct_upload, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using url with uppercased extension' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf_uppercased, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using direct upload with uppercased extension' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf_direct_upload_uppercased, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim exported to primary ATOS'
          include_examples 'a claim with provided reference number'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end
      end
      context 'when in amazon mode' do
        include_context 'with cloud provider switching', cloud_provider: :amazon do
          include_examples 'all file examples'
        end
      end

      context 'when in azure mode' do
        include_context 'with cloud provider switching', cloud_provider: :azure do
          include_examples 'all file examples'
        end
      end
    end

    context 'with json for single claimant, respondent, representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative using welsh template' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_welsh_pdf, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative with non alphanumerics in names' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> do
          FactoryBot.build :json_build_claim_commands,
            number_of_secondary_claimants: 0,
            number_of_secondary_respondents: 0,
            number_of_representatives: 1,
            primary_respondent_traits: [:mr_na_o_leary],
            primary_claimant_traits: [:mr_na_o_malley],
            has_pdf_file: false
        end
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative with unicode chars in phone number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> do
          FactoryBot.build :json_build_claim_commands,
            number_of_secondary_claimants: 0,
            number_of_secondary_respondents: 0,
            number_of_representatives: 1,
            primary_respondent_traits: [:mr_na_unicode],
            primary_claimant_traits: [:mr_na_unicode],
            has_pdf_file: false
        end
      include_context 'with background jobs running'
      it 'has the primary claimant in the et1 txt file with the unicode stripped' do
        # Assert - look for the correct file in the landing folder - will be async
        #
        claimant = normalize_json_claimant(input_primary_claimant_factory.to_h)
        claimant[:mobile_number] = "01234 777666"
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_claimant_for(claimant, errors: errors), -> { errors.join("\n") }
      end

      it 'has the primary respondent in the et1 txt file with the unicode stripped' do
        # Assert - look for the correct file in the landing folder - will be async
        respondent = normalize_json_respondent(input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRespondent' }.data.to_h)
        respondent[:address_telephone_number] = "01234 777666"
        expect(staging_folder.et1_txt_file(output_filename_txt)).to have_respondent_for(respondent, errors: errors), -> { errors.join("\n") }
      end

    end

    context 'with json for multiple claimants, 1 respondent, a representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, 1 respondent and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, multiple respondents, no representatives and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimant, multiple respondents, no representatives with external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimant, multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant, multiple respondents, a representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, multiple respondents, a representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim exported to primary ATOS with internally generated pdf'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, single respondent with postcode that routes to default office' do
      # Uses respondent address with post code 'FF1 1AA'
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:default_office], reference: nil, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to secondary ATOS'
    end

    context 'with json creating an error for single claimant (with no address) and respondent, no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full], primary_claimant_traits: [:mr_first_last, :invalid_address_keys], has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field', background_jobs: :disable do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildPrimaryClaimant' }.uuid
        expect(json_response.dig(:errors).map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                           code: "invalid_address",
                                                                                           title: "Invalid address",
                                                                                           detail: "Invalid address",
                                                                                           source: "/data/2/address_attributes",
                                                                                           command: "BuildPrimaryClaimant",
                                                                                           uuid: expected_uuid
      end
    end

    context 'with json creating an error for single claimant and respondent (with no address), no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full, :invalid_address_keys], has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field', background_jobs: :disable do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildPrimaryRespondent' }.uuid
        expect(json_response.dig(:errors).map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                           code: "invalid_address",
                                                                                           title: "Invalid address",
                                                                                           detail: "Invalid address",
                                                                                           source: "/data/1/address_attributes",
                                                                                           command: "BuildPrimaryRespondent",
                                                                                           uuid: expected_uuid
      end
    end

    context 'with json creating an error for single claimant, respondent and representative (invalid address)' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, primary_representative_traits: [:full, :invalid_address_keys], has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field', background_jobs: :disable do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildPrimaryRepresentative' }.uuid
        expect(json_response.dig(:errors).map(&:symbolize_keys)).to include hash_including status: 422,
                                                                                           code: "invalid_address",
                                                                                           title: "Invalid address",
                                                                                           detail: "Invalid address",
                                                                                           source: "/data/5/address_attributes",
                                                                                           command: "BuildPrimaryRepresentative",
                                                                                           uuid: expected_uuid
      end
    end
  end
end
