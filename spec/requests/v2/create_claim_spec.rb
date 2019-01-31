# frozen_string_literal: true

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
      let(:input_primary_representative_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRepresentative' }.data }
      let(:input_claim_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaim' }.data }
      let(:output_reference) { json_response.dig('meta', 'BuildClaim', 'reference') }
      let(:output_filename_pdf) { "#{output_reference}_ET1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.pdf" }
      let(:output_filename_txt) { "#{output_reference}_ET1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.txt" }
      let(:output_filename_rtf) { "#{output_reference}_ET1_Attachment_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.rtf" }
      let(:output_filename_additional_claimants_txt) { "#{output_reference}_ET1a_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.txt" }
      let(:output_filename_additional_claimants_csv) { "#{output_reference}_ET1a_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.csv" }

      before do
        perform_action
        run_background_jobs
        sleep 0.1
        force_export_now
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
      it 'returns the correct status code' do
        # Assert - Make sure we get a 202 - to say the claim has been accepted and a reference number is created
        expect(response).to have_http_status(:accepted)
      end

      it 'returns status of ok' do
        # Assert - make sure we get status of accepted
        expect(json_response).to include status: 'accepted'
      end

      it 'returns a reference number which contains 12 digits' do
        # Assert - make sure we get status of ok
        expect(json_response.dig('meta', 'BuildClaim')).to include reference: a_string_matching(/\A\d{12}\z/)
      end

      it 'returns a valid reference number that is persisted in the database' do
        result = Claim.where(reference: json_response.dig('meta', 'BuildClaim', 'reference')).first

        # Assert - make sure it is a claim
        expect(result).to be_an_instance_of Claim
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
      it 'returns a reference number which matches the one provided if one was provided' do
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

    context 'with json for single claimant and respondent, no representatives and no reference number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent (with no work address), no representatives, no reference number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, primary_respondent_traits: [:full, :no_work_address]) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimants, 1 respondent and no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 0, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from csv'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
      include_examples 'a claim with a csv file'
    end

    context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded but uppercased filename' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_uppercased, number_of_secondary_respondents: 0, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from csv'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
      include_examples 'a claim with a csv file'
    end

    context 'with json for single claimant, respondent and representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
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
            primary_claimant_traits: [:mr_na_o_malley]
        end
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
            primary_claimant_traits: [:mr_na_unicode]
        end
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

    context 'with json for multiple claimants, 1 respondent and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 1) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, single respondent and representative - with csv file uploaded' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 0, number_of_representatives: 1) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from csv'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
      include_examples 'a claim with a csv file'
    end

    context 'with json for single claimant and multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimant, multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimant, multiple respondents but no representatives - with csv file uploaded' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 2, number_of_representatives: 0) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from csv'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
      include_examples 'a claim with a csv file'
    end

    context 'with json for single claimant, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 1) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 1) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, multiple respondents and a representative - with csv file uploaded' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv, number_of_secondary_respondents: 2, number_of_representatives: 1) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with multiple claimants'
      include_examples 'a claim with multiple claimants from csv'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
      include_examples 'a claim with a csv file'
    end

    context 'with json for single claimant, single respondent and representative - with rtf file uploaded' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) }

      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
      include_examples 'a claim with an rtf file'
    end

    context 'with json for single claimant, single respondent and representative - with rtf file uploaded with uppercased extension' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf_uppercased, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) }

      include_examples 'any claim variation'
      include_examples 'a claim exported to primary ATOS'
      include_examples 'a claim with provided reference number'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
      include_examples 'a claim with an rtf file'
    end

    context 'with json for single claimant, single respondent with postcode that routes to default office' do
      # Uses respondent address with post code 'FF1 1AA'
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:default_office], reference: nil) }
      include_examples 'any claim variation'
      include_examples 'a claim exported to secondary ATOS'
    end

    context 'with json creating an error for single claimant (with no address) and respondent, no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full], primary_claimant_traits: [:mr_first_last, :invalid_address_keys]) }
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field' do
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
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full, :invalid_address_keys]) }
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field' do
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
        json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, primary_representative_traits: [:full, :invalid_address_keys]) }
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field' do
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
