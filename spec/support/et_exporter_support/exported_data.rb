require 'bundler/cli'
module EtApi
  module Test
    class EtExporter
      def self.find_claim_by_reference(reference)
        job = Sidekiq::Worker.jobs.find do |j|
          j['class'] =~ /EtExporter::ExportClaimWorker/ && JSON.parse(j['args'].first).dig('resource', 'reference') == reference
        end
        raise "A claim with reference #{reference} was not exported" if job.nil?

        Claim.new(job)
      end

      def self.assert_claim_not_exported_by_submission_reference(submission_reference)
        Sidekiq::Worker.jobs.none? do |j|
          j['class'] =~ /EtExporter::ExportClaimWorker/ && JSON.parse(j['args'].first).dig('resource', 'reference') == submission_reference
        end
      end

      def self.find_claim_by_submission_reference(reference)
        job = Sidekiq::Worker.jobs.find do |j|
          j['class'] =~ /EtExporter::ExportClaimWorker/ && JSON.parse(j['args'].first).dig('resource', 'submission_reference') == reference
        end
        raise "A claim with reference #{reference} was not exported" if job.nil?

        Claim.new(job)
      end

      # @param [String] reference The reference of the claim to assert has been exported
      # @return [void]
      # @raise [RuntimeError] If the claim has not been exported
      def self.find_response_by_reference(reference)
        job = Sidekiq::Worker.jobs.find do |j|
          j['class'] =~ /EtExporter::ExportResponseWorker/ && JSON.parse(j['args'].first).dig('resource', 'reference') == reference
        end
        raise "A response with reference #{reference} was not exported" if job.nil?

        Response.new(job)
      end

      def self.assert_response_not_exported_by_reference(reference)
        Sidekiq::Worker.jobs.none? do |j|
          j['class'] =~ /EtExporter::ExportResponseWorker/ && JSON.parse(j['args'].first).dig('resource', 'reference') == reference
        end
      end

      class Claim
        include RSpec::Matchers

        def initialize(job)
          self.job = job
          self.data = JSON.parse(job['args'].first, symbolize_names: true)
        end

        def assert_has_file(filename)
          expect(data.dig(:resource, :uploaded_files)).to include(a_hash_including(filename: match(filename)))
        end

        def assert_has_acas_file
          assert_has_file(/\Aacas.*\.pdf\z/)
        end

        def assert_acas_file_contents
          uploaded_file = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] =~ /\Aacas.*\.pdf\z/ }
          raise "No uploaded file starting with 'acas' and ending in '.pdf' has been exported" if uploaded_file.nil?

          file = download(uploaded_file)
          gem_file_path = File.join(Bundler::CLI::Common.select_spec('et_fake_acas_server').full_gem_path, 'lib', 'pdfs', '76 EC (C) Certificate R000080.pdf')
          expect(file.path).to be_a_file_copy_of(gem_file_path)
        end

        def assert_primary_claimant(claimant)
          expect(data.dig(:resource, :primary_claimant)).to include claimant.slice(:first_name, :last_name, :address_telephone_number, :date_of_birth, :email_address, :fax_number, :gender, :mobile_number, :special_needs, :title)
          expect(data.dig(:resource, :primary_claimant, :address)).to include claimant[:address_attributes].to_h.slice(:building, :street, :locality, :county, :postcode, :country)
          expect(data.dig(:resource, :primary_claimant, :contact_preference)).to eq claimant[:contact_preference]&.underscore
        end

        def assert_primary_respondent(respondent)
          expect(data.dig(:resource, :primary_respondent)).to include respondent.slice(:name, :organisation_more_than_one_site, :contact, :dx_number, :address_telephone_number, :work_address_telephone_number, :alt_phone_number, :contact_preference, :fax_number, :organisation_employ_gb, :employment_at_site_number, :disability, :disability_information, :acas_certificate_number, :acas_exemption_code)
          expect(data.dig(:resource, :primary_respondent, :address)).to include respondent[:address_attributes].to_h.slice(:building, :street, :locality, :county, :postcode, :country)
        end

        def assert_et1a_text_file
          expect(et1a_text_file).to have_correct_file_structure.and(have_correct_encoding)
        end

        def et1a_text_file
          uploaded_file = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] =~ /\Aet1a.*\.txt\z/ }
          raise "No uploaded file starting with 'et1a' and ending in '.txt' has been exported" if uploaded_file.nil?

          EtApi::Test::FileObjects::Et1aTxtFile.new download(uploaded_file)
        end

        def et1_pdf_file(template: 'et1-v4-en')
          claimant = data.dig(:resource, :primary_claimant)
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] == "et1_#{scrubber(claimant[:first_name]).downcase}_#{scrubber(claimant[:last_name]).downcase}.pdf" }
          EtApi::Test::FileObjects::Et1PdfFile.new download(file_data), template: template, lookup_root: 'claim_pdf_fields'
        end

        def assert_no_secondary_claimants
          expect(data.dig(:resource, :secondary_claimants)).to be_empty
        end

        def assert_secondary_claimants(claimants)
          expected_claimants = claimants.map do |claimant|
            include(claimant.except(:address_attributes, :allow_video_attendance, :allow_phone_attendance, :no_phone_or_video_reason, :contact_preference).
              merge(address: a_hash_including(claimant[:address_attributes].to_h), contact_preference: claimant[:contact_preference]&.underscore))
          end
          expect(data.dig(:resource, :secondary_claimants)).to match_array(expected_claimants)
        end

        def assert_no_secondary_respondents
          expect(data.dig(:resource, :secondary_respondents)).to be_empty
        end

        def assert_secondary_respondents(respondents)
          expected_respondents = respondents.map do |respondent|
            include(respondent.except(:address_attributes, :work_address_attributes).
              merge(address: a_hash_including(respondent[:address_attributes].to_h), work_address: a_hash_including(respondent[:work_address_attributes].to_h)))
          end
          expect(data.dig(:resource, :secondary_respondents)).to match_array(expected_respondents)
        end

        def assert_no_representatives
          expect(data.dig(:resource, :primary_representative)).to be_nil
        end

        def assert_representative(representative)
          expect(data.dig(:resource, :primary_representative)).to include representative.except(:address_attributes).merge(address: a_hash_including(representative[:address_attributes].to_h))
        end

        def csv_file
          claimant = data.dig(:resource, :primary_claimant)
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] == "et1a_#{claimant[:first_name]}_#{claimant[:last_name]}.csv" }
          download(file_data)
        end

        def claim_details_file
          claimant = data.dig(:resource, :primary_claimant)
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] == "et1_attachment_#{claimant[:first_name]}_#{claimant[:last_name]}.rtf" }
          download(file_data)
        end

        private

        attr_accessor :job, :data

        def download(uploaded_file)
          file = Tempfile.new
          file.binmode
          HTTParty.get(uploaded_file[:url]) do |chunk|
            file.write(chunk)
          end
          file.rewind
          file
        end

        def scrubber(text)
          text.gsub(/\s/, '_').gsub(/\W/, '')
        end

      end

      class Response
        include RSpec::Matchers

        def initialize(job)
          self.job = job
          self.data = JSON.parse(job['args'].first, symbolize_names: true)
        end

        def assert_response_details(response)
          expect(data[:resource]).to include(response.to_h.except(:additional_information_key, :pdf_template_reference, :email_template_reference))
        end

        def assert_respondent(respondent)
          expect(data.dig(:resource, :respondent)).to include(respondent.to_h.except(:work_address_attributes, :address_attributes).merge(address: respondent[:address_attributes]&.to_h, work_address: respondent[:work_address_attributes]&.to_h))
        end

        def assert_representative(representative)
          if representative.blank?
            expect(data.dig(:resource, :representative)).to be_nil
          else
            expect(data.dig(:resource, :representative)).to include(representative.to_h.except(:address_attributes, :allow_video_attendance, :allow_phone_attendance).merge(address: representative[:address_attributes]&.to_h))
          end
        end

        def et3_pdf_file(template: 'et3-v3-en')
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] == "et3_atos_export.pdf" }

          EtApi::Test::FileObjects::Et3PdfFile.new download(file_data), template: template, lookup_root: 'response_pdf_fields'
        end

        def additional_information_file
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] =~ /\Aadditional_information\.(?:pdf|rtf)\z/ }
          EtApi::Test::FileObjects::Et3AdditionalInformationFile.new download(file_data)
        end

        private

        attr_accessor :job, :data

        def download(uploaded_file)
          file = Tempfile.new
          file.binmode
          HTTParty.get(uploaded_file[:url]) do |chunk|
            file.write(chunk)
          end
          file.rewind
          file
        end
      end
    end
  end
end
