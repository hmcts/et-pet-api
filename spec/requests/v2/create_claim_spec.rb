# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Create Claim Request', type: :request do
  include_context 'with local storage'
  include_context 'with gov uk notify emails sent monitor'

  describe 'POST /api/v2/claims/build_claim' do
    let(:default_headers) do
      {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      }
    end
    let(:errors) { [] }
    let(:json_response) { JSON.parse(response.body).with_indifferent_access }

    shared_context 'with fake sidekiq' do
      around do |example|

        original_adapter = ActiveJob::Base.queue_adapter
        ActiveJob::Base.queue_adapter = :test
        ActiveJob::Base.queue_adapter.enqueued_jobs.clear
        ActiveJob::Base.queue_adapter.performed_jobs.clear
        example.run
      ensure
        ActiveJob::Base.queue_adapter = original_adapter

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
      end
    end

    shared_context 'with setup for claims' do |json_factory:|
      let(:input_factory) { json_factory.call }

      # @return [EtApi::Test::EtExporter] The exporter class to use for testing
      let(:et_exporter) { EtApi::Test::EtExporter }

      # A private scrubber to set expectations for the filename - replaces white space with underscores and any non word chars are removed
      scrubber = ->(text) { text.gsub(/\s/, '_').gsub(/\W/, '') }

      let(:input_primary_claimant_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryClaimant' }.data }
      let(:input_secondary_claimants_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildSecondaryClaimants' }.data }
      let(:input_primary_respondent_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRespondent' }.data }
      let(:input_secondary_respondents_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildSecondaryRespondents' }.data }
      let(:input_primary_representative_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRepresentative' }.try(:data) }
      let(:input_claim_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaim' }.data }
      let(:input_claimants_file_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimantsFile' }.try(:data) }
      let(:input_claim_details_file_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimDetailsFile' }.try(:data) }
      let(:csv_claimants_emulated_as_json) do
        file = input_claimants_file_factory
        next [] if file.nil?

        full_path = Rails.root.join('spec', 'fixtures', file.filename.downcase).to_s
        raise "csv claimants not from fixtures - code needs writing to read the file from http. The file is #{full_path}" unless File.exist?(full_path)

        CSV.foreach(full_path, headers: true).each_with_object([]) do |row, acc|
          data = row.to_hash
          acc << build(:json_claimant_data,
                       title: data['Title']&.strip&.downcase&.capitalize,
                       first_name: data['First name'],
                       last_name: data['Last name'],
                       address_attributes:
                         build(:json_address_data,
                               building: data['Building number or name'],
                               street: data['Street'],
                               locality: data['Town/city'],
                               county: data['County'],
                               post_code: data['Postcode']),
                       date_of_birth: data['Date of birth'])
        end
      end
      let(:output_reference) { json_response.dig('meta', 'BuildClaim', 'reference') }
      let(:output_filename_pdf) { "#{output_reference}_ET1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.pdf" }
      let(:output_filename_txt) { "#{output_reference}_ET1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.txt" }
      let(:output_filename_claim_details) { "#{output_reference}_ET1_Attachment_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.pdf" }
      let(:output_filename_additional_claimants_txt) { "#{output_reference}_ET1a_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.txt" }
      let(:output_filename_additional_claimants_csv) { "#{output_reference}_ET1a_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.csv" }
      before do
        perform_action
      end

      def perform_action
        json_data = input_factory.to_json
        post '/api/v2/claims/build_claim', params: json_data, headers: default_headers
      end
    end

    shared_examples 'any claim variation' do
      it 'returns status of ok', background_jobs: :disable do
        # Assert - make sure we get status of accepted
        aggregate_failures 'validating response' do
          expect(response).to have_http_status(:accepted)
          expect(json_response).to include status: 'accepted'
          expect(json_response.dig('meta', 'BuildClaim')).to include reference: a_string_matching(/\A\d{12}\z/)
          office = json_response.dig('meta', 'BuildClaim', 'office').symbolize_keys
          expect(office).to include code: instance_of(Integer),
                                    name: instance_of(String),
                                    telephone: instance_of(String),
                                    address: instance_of(String),
                                    email: instance_of(String)
        end
      end

      it 'returns a valid reference number that is persisted in the database', background_jobs: :disable do
        result = Claim.where(reference: json_response.dig('meta', 'BuildClaim', 'reference')).first

        # Assert - make sure it is a claim
        expect(result).to be_an_instance_of Claim
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

      it 'returns the status as not accepted', background_jobs: :disable do
        # Assert - Make sure we get the uuid in the response
        expect(json_response).to include status: 'not_accepted', uuid: input_factory.uuid
      end
    end

    shared_examples 'a claim exported to et_exporter' do |assert_missing_et1a: true|
      it 'has the primary claimaint in the payload' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_primary_claimant(input_primary_claimant_factory.to_h)
      end

      it 'has the primary respondent in the payload' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_primary_respondent(input_primary_respondent_factory.to_h)
      end

      it 'creates a valid pdf file with the data filled in correctly' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).et1_pdf_file(template: input_claim_factory.pdf_template_reference).assert_correct_contents_for(
          claim: input_claim_factory,
          claimants: [input_primary_claimant_factory] + input_secondary_claimants_factory + csv_claimants_emulated_as_json,
          respondents: [input_primary_respondent_factory] + input_secondary_respondents_factory,
          representative: input_primary_representative_factory,
          assert_missing_et1a: assert_missing_et1a
        )
      end
    end

    shared_examples 'a claim exported to et_exporter with single claimant' do
      it 'has no secondary claimants' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_no_secondary_claimants
      end
    end

    shared_examples 'a claim exported to et_exporter with single respondent' do
      it 'has no secondary respondents' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_no_secondary_respondents
      end
    end

    shared_examples 'a claim exported to et_exporter with no representatives' do
      it 'has no representatives' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_no_representatives
      end
    end

    shared_examples 'a claim exported to et_exporter with multiple claimants' do
      it 'has multiple claimants' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        secondary_claimants = input_factory.data.find { |n| n.command == 'BuildSecondaryClaimants' }.data.map(&:to_h)
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_secondary_claimants(secondary_claimants)
      end

      it 'has the et1a text file attached' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_et1a_text_file
      end

      it 'stores an ET1a txt file with all of the claimants in the correct format' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        claimants = normalize_json_claimants(input_secondary_claimants_factory.map(&:to_h))
        expect(et_exporter.find_claim_by_submission_reference(submission_reference).et1a_text_file).to have_claimants_for(claimants, errors: errors), -> { errors.join("\n") }
      end
    end

    shared_examples 'a claim exported to et_exporter with multiple claimants from csv' do
      it 'has multiple claimants' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        claimants = normalize_claimants_from_file(dates: :string)
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_secondary_claimants(claimants)
      end
    end

    shared_examples 'a claim exported to et_exporter with a csv file' do
      it 'has a csv file' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        input_csv_file = input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimantsFile' }.data.filename
        input_csv_file_full_path = File.absolute_path(File.join('..', '..', '..', 'fixtures', input_csv_file.downcase), __FILE__)
        expect(et_exporter.find_claim_by_submission_reference(submission_reference).csv_file.path).to be_a_file_copy_of(input_csv_file_full_path)
      end
    end

    shared_examples 'a claim exported to et_exporter with a representative' do
      it 'has a representative' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_representative(input_primary_representative_factory.to_h)
      end
    end

    shared_examples 'a claim exported to et_exporter with multiple respondents' do
      it 'has multiple respondents' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        secondary_respondents = input_factory.data.find { |n| n.command == 'BuildSecondaryRespondents' }.data.map(&:to_h)
        et_exporter.find_claim_by_submission_reference(submission_reference).assert_secondary_respondents(secondary_respondents)
      end
    end

    shared_examples 'a claim exported to et_exporter with a claim details file' do
      it 'has a claim details file' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        expect(et_exporter.find_claim_by_submission_reference(submission_reference).claim_details_file.path).to be_a_pdf_file_containing_title('It is an example test rtf-file')
      end
    end

    shared_examples 'a claim exported with an attached acas certificate' do
      it 'exports the acas certificate ready for external systems to pick up' do
        ref = output_reference
        et_exporter.find_claim_by_reference(ref).assert_has_acas_file
      end

      it 'saves the acas file correctly' do
        ref = output_reference
        et_exporter.find_claim_by_reference(ref).assert_acas_file_contents
      end
    end

    shared_examples 'email validation using standard template' do
      it 'sends a govuk notify email to the respondent with the pdf attached using the standard template' do
        reference = json_response.dig(:meta, 'BuildClaim', :reference)
        email_sent = emails_sent.new_claim_email_for(reference: reference, template_reference: 'et1-v1-en')
        expect(email_sent).to have_correct_content_for(input_claim_factory, input_primary_claimant_factory, input_claimants_file_factory, input_claim_details_file_factory, reference: reference)
      end
    end

    shared_examples 'email validation using welsh template' do
      it 'sends a govuk notify email to the respondent with the pdf attached using the welsh template' do
        reference = json_response.dig(:meta, 'BuildClaim', :reference)
        email_sent = emails_sent.new_claim_email_for(reference: reference, template_reference: 'et1-v1-cy')
        expect(email_sent).to have_correct_content_for(input_claim_factory, input_primary_claimant_factory, input_claimants_file_factory, input_claim_details_file_factory, reference: reference)
      end
    end

    context 'with json for single claimant and respondent, no representatives and no acas number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, primary_respondent_traits: [:full, :no_acas_no_jurisdiction]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with no representatives'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant and respondent (with no work address), no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, reference: nil, primary_respondent_traits: [:full, :no_work_address]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported with an attached acas certificate'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with no representatives'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant and respondent but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with no representatives'
      include_examples 'email validation using standard template'
    end

    context 'with json for multiple claimants, 1 respondent and no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with multiple claimants'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with no representatives'
      include_examples 'email validation using standard template'
    end

    context 'with json involving external files' do
      context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using direct upload' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 0, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported to et_exporter with multiple claimants from csv'
        include_examples 'a claim exported to et_exporter with single respondent'
        include_examples 'a claim exported to et_exporter with no representatives'
        include_examples 'a claim exported to et_exporter with a csv file'
        include_examples 'email validation using standard template'
      end

      context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using direct upload but uppercased filename' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload_uppercased, number_of_secondary_respondents: 0, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported to et_exporter with multiple claimants from csv'
        include_examples 'a claim exported to et_exporter with single respondent'
        include_examples 'a claim exported to et_exporter with no representatives'
        include_examples 'a claim exported to et_exporter with a csv file'
        include_examples 'email validation using standard template'
      end

      context 'with json for multiple claimants, single respondent and representative - with csv file uploaded using direct upload' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 0, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported to et_exporter with multiple claimants from csv'
        include_examples 'a claim exported to et_exporter with single respondent'
        include_examples 'a claim exported to et_exporter with a representative'
        include_examples 'a claim exported to et_exporter with a csv file'
        include_examples 'email validation using standard template'
      end

      context 'with json for multiple claimants, multiple respondents but no representatives - with csv file uploaded using direct upload' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 2, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported with an attached acas certificate'
        include_examples 'a claim exported to et_exporter with multiple claimants from csv'
        include_examples 'a claim exported to et_exporter with multiple respondents'
        include_examples 'a claim exported to et_exporter with no representatives'
        include_examples 'a claim exported to et_exporter with a csv file'
        include_examples 'email validation using standard template'
      end

      context 'with json for multiple claimants, multiple respondents and a representative - with csv file uploaded using direct upload' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 2, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported to et_exporter with multiple claimants from csv'
        include_examples 'a claim exported to et_exporter with multiple respondents'
        include_examples 'a claim exported to et_exporter with a representative'
        include_examples 'a claim exported to et_exporter with a csv file'
        include_examples 'email validation using standard template'
      end

      context 'with json for single claimant, single respondent and representative - with claim details file uploaded using direct upload' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf_direct_upload, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported to et_exporter with single claimant'
        include_examples 'a claim exported to et_exporter with single respondent'
        include_examples 'a claim exported to et_exporter with a representative'
        include_examples 'a claim exported to et_exporter with a claim details file'
        include_examples 'email validation using standard template'
      end

      context 'with json for single claimant, single respondent and representative - with claim details file uploaded using direct upload with uppercased extension' do
        include_context 'with fake sidekiq'
        include_context 'with setup for claims',
                        json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_rtf_direct_upload_uppercased, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
        include_context 'with background jobs running'
        include_examples 'any claim variation'
        include_examples 'a claim exported to et_exporter'
        include_examples 'a claim exported to et_exporter with single claimant'
        include_examples 'a claim exported to et_exporter with single respondent'
        include_examples 'a claim exported to et_exporter with a representative'
        include_examples 'a claim exported to et_exporter with a claim details file'
        include_examples 'email validation using standard template'
      end
    end

    context 'with json for single claimant, respondent and representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant, respondent and representative with worked notice period or paid in lieu' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, claim_traits: [:full, :worked_notice_period]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with a representative'
    end

    context 'with json for single claimant, respondent and representative using welsh template' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, :with_welsh_pdf, :with_welsh_email, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter', assert_missing_et1a: false
      # We cannot verify an et1a correctly as there are clashing field names between the et1 and et1a forms
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using welsh template'
    end

    context 'with json for single claimant, respondent and representative with non alphanumerics in names' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: lambda {
                        FactoryBot.build(:json_build_claim_commands, # rubocop:disable FactoryBot/SyntaxMethods
                                         number_of_secondary_claimants: 0,
                                         number_of_secondary_respondents: 0,
                                         number_of_representatives: 1,
                                         primary_respondent_traits: [:mr_na_o_leary],
                                         primary_claimant_traits: [:mr_na_o_malley])
                      }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant, respondent and representative with unicode chars in phone number' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: lambda {
                        FactoryBot.build(:json_build_claim_commands, # rubocop:disable FactoryBot/SyntaxMethods
                                         number_of_secondary_claimants: 0,
                                         number_of_secondary_respondents: 0,
                                         number_of_representatives: 1,
                                         primary_respondent_traits: [:mr_na_unicode],
                                         primary_claimant_traits: [:mr_na_unicode])
                      }
      include_context 'with background jobs running'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant with N/K gender, 1 respondent and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, primary_claimant_traits: [:no_gender_first_last]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using standard template'
    end

    context 'with json for multiple claimants, 1 respondent and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with multiple claimants'
      include_examples 'a claim exported to et_exporter with single respondent'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant and multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 4, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with multiple respondents'
      include_examples 'a claim exported to et_exporter with no representatives'
      include_examples 'email validation using standard template'
    end

    context 'with json for multiple claimant, multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 0) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with multiple claimants'
      include_examples 'a claim exported to et_exporter with multiple respondents'
      include_examples 'a claim exported to et_exporter with no representatives'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with single claimant'
      include_examples 'a claim exported to et_exporter with multiple respondents'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using standard template'
    end

    context 'with json for multiple claimants, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 1) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim exported to et_exporter'
      include_examples 'a claim exported to et_exporter with multiple claimants'
      include_examples 'a claim exported to et_exporter with multiple respondents'
      include_examples 'a claim exported to et_exporter with a representative'
      include_examples 'email validation using standard template'
    end

    context 'with json for single claimant, single respondent with postcode that routes to default office' do
      # Uses respondent address with post code 'FF1 1AA'
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:default_office], reference: nil) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'email validation using standard template'

      it 'is not exported' do
        submission_reference = input_factory.data.find { |node| node.command == 'BuildClaim' }.data.submission_reference
        et_exporter.assert_claim_not_exported_by_submission_reference(submission_reference)
      end
    end

    context 'with json creating an error for single claimant (with no address) and respondent, no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full], primary_claimant_traits: [:mr_first_last, :invalid_address_keys]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field', background_jobs: :disable do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildPrimaryClaimant' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
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
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full, :invalid_address_keys]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field', background_jobs: :disable do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildPrimaryRespondent' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
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
                      json_factory: -> { FactoryBot.build(:json_build_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, primary_representative_traits: [:full, :invalid_address_keys]) } # rubocop:disable FactoryBot/SyntaxMethods
      include_context 'with background jobs running'
      include_examples 'any bad request error variation'

      it 'has the correct error in the address_attributes field', background_jobs: :disable do
        expected_uuid = input_factory.data.detect { |d| d.command == 'BuildPrimaryRepresentative' }.uuid
        expect(json_response[:errors].map(&:symbolize_keys)).to include hash_including status: 422,
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
