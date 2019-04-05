require 'rails_helper'
RSpec.describe 'Import Claim Request', type: :request do
  describe 'POST /api/v2/claims/import_claim' do
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

      let(:emails_sent) do
        EtApi::Test::EmailsSent.new
      end

      let(:input_primary_claimant_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryClaimant' }.data }
      let(:input_secondary_claimants_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildSecondaryClaimants' }.data }
      let(:input_primary_respondent_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRespondent' }.data }
      let(:input_secondary_respondents_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildSecondaryRespondents' }.data }
      let(:input_primary_representative_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPrimaryRepresentative' }.try(:data) }
      let(:input_claim_factory) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaim' }.data }
      let(:created_claim) { Claim.where(reference: input_claim_factory.reference).first }

      before do
        perform_action
      end

      def perform_action
        json_data = input_factory.to_json
        post '/api/v2/claims/import_claim', params: json_data, headers: default_headers
      end

      def force_export_now
        EtAtosExport::ClaimsExportJob.perform_now
      end
    end

    shared_examples 'any claim variation' do
      it 'returns the correct status code', background_jobs: :disable do
        # Assert - Make sure we get a 202 - to say the claim has been accepted for import
        expect(response).to have_http_status(:accepted)
      end

      it 'returns status of ok', background_jobs: :disable do
        # Assert - make sure we get status of accepted
        expect(json_response).to include status: 'accepted'
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

      it 'does not export anything' do
        aggregate_failures "checking nothing has been exported" do
          expect(staging_folder).to be_empty
          expect(secondary_staging_folder).to be_empty
        end
      end

      it 'does not send any emails ever' do
        expect(emails_sent).to be_empty
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

    shared_examples 'a claim with single respondent' do
      it 'has no secondary respondents in the database' do
        # Assert
        expect(created_claim.secondary_respondents).to be_empty
      end
    end

    shared_examples 'a claim with multiple respondents' do
      it 'has the secondary respondents in the database' do
        # Assert
        respondents = normalize_json_respondents(input_secondary_respondents_factory.map(&:to_h))
        db_respondents = created_claim.secondary_respondents.map do |r|
          json = r.as_json only: [:name, :acas_certificate_number, :acas_exemption_code, :address_telephone_number, :alt_phone_number,
                                  :contact, :contact_preference, :disability, :disability_information, :dx_number, :email_address,
                                  :employment_at_site_number, :fax_number, :organisation_employ_gb, :organisation_more_than_one_site, :work_address_telephone_number],
                           include: { address: { only: [:building, :street, :locality, :county, :post_code] },
                                      work_address: { only: [:building, :street, :locality, :county, :post_code] } }
          json.deep_symbolize_keys
        end
        expect(db_respondents).to eql respondents
      end
    end

    shared_examples 'a claim with single claimant' do
      it 'has no secondary claimants in the database' do
        # Assert
        expect(created_claim.secondary_claimants).to be_empty
      end
    end

    shared_examples 'a claim with multiple claimants from json' do
      it 'has the secondary claimants in the database' do
        # Assert
        claimants = normalize_json_claimants(input_secondary_claimants_factory.map(&:to_h))
        db_claimants = created_claim.secondary_claimants.map do |c|
          json = c.as_json only: [:first_name, :last_name, :title, :gender, :address_telephone_number, :contact_preference, :date_of_birth, :email_address, :mobile_number, :special_needs, :fax_number],
                           include: { address: { only: [:building, :street, :locality, :county, :post_code] } }
          json.deep_symbolize_keys
        end
        expect(db_claimants).to eql claimants
      end
    end

    shared_examples 'a claim with multiple claimants from csv' do
      it 'has the secondary claimants in the database' do
        # Assert
        claimants = normalize_claimants_from_file
        db_claimants = created_claim.secondary_claimants.map do |c|
          json = c.as_json only: [:first_name, :last_name, :title, :date_of_birth],
                           include: { address: { only: [:building, :street, :locality, :county, :post_code] } }
          json.deep_symbolize_keys
        end
        expect(db_claimants).to eql claimants
      end
    end

    shared_examples 'a claim with no representatives' do
      it 'has no representative in the database' do
        # Assert
        expect(created_claim.primary_representative).to be nil
      end
    end

    shared_examples 'a claim with a representative' do
      it 'has the representative in the database' do
        # Assert
        rep = normalize_json_representative(input_primary_representative_factory.to_h)
        primary_rep = created_claim.primary_representative
        db_rep = primary_rep.as_json include: { address: { only: [:building, :street, :locality, :county, :post_code] } },
                                     only: [:organisation_name, :reference, :representative_type, :name, :mobile_number,
                                            :fax_number, :email_address, :dx_number, :contact_preference, :address_telephone_number]
        expect(db_rep.deep_symbolize_keys).to eql rep
      end
    end

    shared_examples 'a claim with a csv file' do
      let(:input_csv_file) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimantsFile' }.data.filename }

      it 'stores the csv file in the database / remote file storage' do
        # Assert - look for the correct file in the claim
        file = created_claim.uploaded_files.where(filename: input_csv_file).first

        Dir.mktmpdir do |dir|
          full_path = File.join(dir, input_csv_file)
          file.download_blob_to(full_path)
          input_csv_file_full_path = File.absolute_path(File.join('..', '..', '..', 'fixtures', input_csv_file), __FILE__)
          expect(full_path).to be_a_file_copy_of(input_csv_file_full_path.downcase)
        end
      end
    end

    shared_examples 'a claim with an rtf file' do
      let(:input_rtf_file) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildClaimDetailsFile' }.data.filename }

      it 'stores the rtf file with the correct filename and is a copy of the original' do
        # Assert - look for the correct file in the database and check its contents
        file = created_claim.uploaded_files.where(filename: input_rtf_file).first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, input_rtf_file)
          file.download_blob_to(full_path)
          input_rtf_file_full_path = File.absolute_path(File.join('..', '..', '..', 'fixtures', input_rtf_file.downcase), __FILE__)
          expect(full_path).to be_a_file_copy_of(input_rtf_file_full_path)
        end
      end
    end

    # @TODO RST-1741 - Once we only generating pdf's internally for et1 - the examples in here can be merged with the normal output folder shared examples
    shared_examples 'a claim imported with internally generated pdf' do
      # A private scrubber to set expectations for the filename - replaces white space with underscores and any non word chars are removed
      scrubber = ->(text) { text.gsub(/\s/, '_').gsub(/\W/, '').downcase }

      it 'creates a valid pdf file the data filled in correctly' do
        # Assert - Make sure we have a file with the correct contents and correct filename pattern somewhere in the zip files produced
        filename = "et1_#{scrubber.call input_primary_claimant_factory.first_name}_#{scrubber.call input_primary_claimant_factory.last_name}.pdf"
        file = created_claim.uploaded_files.where(filename: filename).first
        tempfile = Tempfile.new

        file.download_blob_to(tempfile.path)

        file_object = EtApi::Test::FileObjects::Et1PdfFile.new tempfile, template: input_claim_factory.pdf_template_reference, lookup_root: 'claim_pdf_fields'

        expect(file_object).to have_correct_contents_for(
          claim: input_claim_factory,
          claimants: [input_primary_claimant_factory] + input_secondary_claimants_factory,
          respondents: [input_primary_respondent_factory] + input_secondary_respondents_factory,
          representative: input_primary_representative_factory
        )
      end
    end

    shared_examples 'a claim imported with externally generated pdf' do
      let(:input_pdf_file) { input_factory.data.detect { |command_factory| command_factory.command == 'BuildPdfFile' }.data.filename }

      it 'stores the pdf file with the correct filename and is a copy of the original' do
        # Assert - look for the correct file in the database and check its contents
        file = created_claim.uploaded_files.where(filename: input_pdf_file).first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, input_pdf_file)
          file.download_blob_to(full_path)
          input_pdf_file_full_path = File.absolute_path(File.join('..', '..', '..', 'fixtures', input_pdf_file.downcase), __FILE__)
          expect(full_path).to be_a_file_copy_of(input_pdf_file_full_path)
        end
      end
    end

    context 'with json for single claimant and respondent, no representatives and an external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and respondent but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimants, 1 respondent, no representatives and an external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimants, 1 respondent and no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant, respondent, representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative using welsh template' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_welsh_pdf, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, respondent and representative with non alphanumerics in names' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: lambda {
          FactoryBot.build :json_import_claim_commands,
            number_of_secondary_claimants: 0,
            number_of_secondary_respondents: 0,
            number_of_representatives: 1,
            primary_respondent_traits: [:mr_na_o_leary],
            primary_claimant_traits: [:mr_na_o_malley],
            has_pdf_file: true
        }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, 1 respondent, a representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, 1 respondent and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with single respondent'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, multiple respondents, no representatives and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant and multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimant, multiple respondents, no representatives with external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for multiple claimant, multiple respondents but no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with no representatives'
    end

    context 'with json for single claimant, multiple respondents, a representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for single claimant, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with single claimant'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, multiple respondents, a representative and external pdf' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with externally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    context 'with json for multiple claimants, multiple respondents and a representative' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 4, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: false) }
      include_context 'with background jobs running'
      include_examples 'any claim variation'
      include_examples 'a claim imported with internally generated pdf'
      include_examples 'a claim with multiple claimants from json'
      include_examples 'a claim with multiple respondents'
      include_examples 'a claim with a representative'
    end

    # @TODO RST-1741 - When we are only using internally generated pdf's - all of the examples in this block must have their has_pdf_file set to false
    # @TODO RST-1676 - The amazon context can be removed and the shared examples expanded back into the only context using them
    context 'with json involving external files' do
      shared_examples 'all file examples' do
        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using url but uppercased filename' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv_uppercased, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and no representative - with csv file uploaded using direct upload but uppercased filename' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv_direct_upload_uppercased, number_of_secondary_respondents: 0, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and representative - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, single respondent and representative - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents but no representatives - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents but no representatives - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 2, number_of_representatives: 0, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with no representatives'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents and a representative - with csv file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for multiple claimants, multiple respondents and a representative - with csv file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_csv_direct_upload, number_of_secondary_respondents: 2, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with multiple claimants from csv'
          include_examples 'a claim with multiple respondents'
          include_examples 'a claim with a representative'
          include_examples 'a claim with a csv file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using url' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_rtf, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using direct upload' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_rtf_direct_upload, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using url with uppercased extension' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_rtf_uppercased, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
          include_examples 'a claim with single claimant'
          include_examples 'a claim with single respondent'
          include_examples 'a claim with a representative'
          include_examples 'a claim with an rtf file'
        end

        context 'with json for single claimant, single respondent and representative - with rtf file uploaded using direct upload with uppercased extension' do
          include_context 'with fake sidekiq'
          include_context 'with setup for claims',
            json_factory: -> { FactoryBot.build(:json_import_claim_commands, :with_rtf_direct_upload_uppercased, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, has_pdf_file: true) }
          include_context 'with background jobs running'
          include_examples 'any claim variation'
          include_examples 'a claim imported with externally generated pdf'
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

    context 'with json creating an error for single claimant (with no address) and respondent, no representatives' do
      include_context 'with fake sidekiq'
      include_context 'with setup for claims',
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full], primary_claimant_traits: [:mr_first_last, :invalid_address_keys], has_pdf_file: true) }
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
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 0, primary_respondent_traits: [:full, :invalid_address_keys], has_pdf_file: true) }
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
        json_factory: -> { FactoryBot.build(:json_import_claim_commands, number_of_secondary_claimants: 0, number_of_secondary_respondents: 0, number_of_representatives: 1, primary_representative_traits: [:full, :invalid_address_keys], has_pdf_file: true) }
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
