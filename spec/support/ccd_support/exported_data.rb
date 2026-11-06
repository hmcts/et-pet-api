require 'bundler/cli'
module EtApi
  module Test
    class CcdExporter
      def self.test_ccd_client
        EtCcdClient::UiClient.new.tap(&:login)
      end

      def self.find_claim_by_reference(reference)
        raise "Not yet converted to ccd"
        job = find_claim_job do |j|
          j.dig('resource', 'reference') == reference
        end
        raise "A claim with reference #{reference} was not exported" if job.nil?

        Claim.new(job)
      end

      def self.assert_claim_not_exported_by_submission_reference(submission_reference)
        raise "Not yet converted to ccd"
        job = find_claim_job do |j|
          j.dig('resource', 'reference') == submission_reference
        end

        raise "A claim with submission reference #{submission_reference} was not expected to be exported, but it was" unless job.nil?
      end

      def self.find_claim_by_submission_reference(reference)
        ccd_case = test_ccd_client.caseworker_search_latest_by_reference(reference, case_type_id: 'Manchester')

        raise "A claim with reference #{reference} was not exported" if ccd_case.nil?

        Claim.new(ccd_case)
      end

      # @param [String] reference The reference of the claim to assert has been exported
      # @return [void]
      # @raise [RuntimeError] If the claim has not been exported
      def self.find_response_by_reference(reference)
        raise "Not yet converted to ccd"
        job = find_response_job do |j|
          j.dig('resource', 'reference') == reference
        end
        raise "A response with reference #{reference} was not exported" if job.nil?

        Response.new(job)
      end

      def self.assert_response_not_exported_by_reference(reference)
        raise "Not yet converted to ccd"
        job = find_response_job do |j|
          j.dig('resource', 'reference') == reference
        end

        raise "A response with reference #{reference} was not expected to be exported, but it was" unless job.nil?
      end

      def self.find_claim_job(use_active_job: Rails.application.config.try(:use_active_job))
        raise "Not yet converted to ccd"
        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        jobs.find do |j|
          j['job_class'] =~ /EtExporter::ExportClaimJob/ && yield(JSON.parse(j['arguments'].first))
        end
      end

      def self.find_response_job(use_active_job: Rails.application.config.try(:use_active_job))
        raise "Not yet converted to ccd"
        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        jobs.find do |j|
          j['job_class'] =~ /EtExporter::ExportResponseJob/ && yield(JSON.parse(j['arguments'].first))
        end
      end

      class Claim
        include RSpec::Matchers

        def initialize(ccd_case)
          self.ccd_case = ccd_case
        end

        def assert_has_file(filename)
          raise "Not yet converted to ccd"
          expect(data.dig(:resource, :uploaded_files)).to include(a_hash_including(filename: match(filename)))
        end

        def assert_has_acas_file
          raise "Not yet converted to ccd"
          assert_has_file(/\Aacas.*\.pdf\z/)
        end

        def assert_acas_file_contents
          raise "Not yet converted to ccd"
          uploaded_file = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] =~ /\Aacas.*\.pdf\z/ }
          raise "No uploaded file starting with 'acas' and ending in '.pdf' has been exported" if uploaded_file.nil?

          file = download(uploaded_file)
          gem_file_path = File.join(Bundler::CLI::Common.select_spec('et_fake_acas_server').full_gem_path, 'lib', 'pdfs', '76 EC (C) Certificate R000080.pdf')
          expect(file.path).to be_a_file_copy_of(gem_file_path)
        end

        def assert_acas_data_in_respondents
          raise "Not yet converted to ccd"
          respondents = ([data.dig(:resource, :primary_respondent)] + data.dig(:resource, :secondary_respondents)).select { |respondent| respondent[:acas_certificate_number].present? }
          expect(respondents).to all(include(acas_issue_date: "2026-01-08", acas_receipt_date: "2025-09-29"))
        end

        def assert_primary_claimant(claimant)
          expect(ccd_case.dig('case_fields', 'claimantIndType')).to include "claimant_first_names" => claimant[:first_name],
                                                                            "claimant_last_name" => claimant[:last_name],
                                                                            "claimant_date_of_birth" => claimant[:date_of_birth],
                                                                            "claimant_gender" => claimant[:gender],
                                                                            "claimant_title1" => claimant[:title]

          expect(ccd_case.dig('case_fields', 'claimantType')).to include "claimant_phone_number" => claimant[:address_telephone_number],
                                                                         "claimant_email_address" => claimant[:email_address],
                                                                         "claimant_mobile_number" => claimant[:mobile_number],
                                                                         "claimant_contact_preference" => claimant[:contact_preference]&.humanize,
                                                                         "claimant_addressUK" => a_hash_including(
                                                                           "AddressLine1" => claimant.dig(:address_attributes, :building),
                                                                           "AddressLine2" => claimant.dig(:address_attributes, :street),
                                                                           "PostTown" => claimant.dig(:address_attributes, :locality),
                                                                           "County" => claimant.dig(:address_attributes, :county),
                                                                           "PostCode" => claimant.dig(:address_attributes, :post_code),
                                                                           "Country" => claimant.dig(:address_attributes, :country)
                                                                         )
          expect(ccd_case.dig('case_fields', 'claimantOtherType')).to include "claimant_disabled" => claimant[:special_needs].present? ? 'Yes' : 'No'
        end

        def assert_primary_respondent(respondent)
          ccd_respondent = ccd_case.dig('case_fields', 'respondentCollection').first.fetch('value')
          expect(ccd_respondent).to include "respondent_name" => respondent[:name],
                                             "respondent_phone1" => respondent[:address_telephone_number]
          work_phone_number = if respondent[:work_address_attributes].present?
                                respondent[:work_address_telephone_number]
                              else
                                respondent[:address_telephone_number]
                              end
          expect(ccd_case.dig('case_fields', 'claimantWorkAddress')).to include "claimant_work_phone_number" => work_phone_number
          expect(ccd_respondent).to include "respondent_ACAS" => respondent[:acas_certificate_number]
          unless respondent[:acas_certificate_number].present?
            expect(ccd_respondent).to include "respondent_ACAS_no" => acas_exemption_reason(respondent[:acas_exemption_code])
          end
          expect(ccd_respondent.fetch('respondent_address')).to include(
            "AddressLine1" => respondent.dig(:address_attributes, :building),
            "AddressLine2" => respondent.dig(:address_attributes, :street),
            "PostTown" => respondent.dig(:address_attributes, :locality),
            "County" => respondent.dig(:address_attributes, :county),
            "PostCode" => respondent.dig(:address_attributes, :post_code),
            "Country" => nil
          )
          expect(ccd_respondent).to include "respondent_ACAS_question" => respondent[:acas_certificate_number].present? ? 'Yes' : 'No'
        end

        def assert_et1a_text_file
          raise "Not yet converted to ccd"
          expect(et1a_text_file).to have_correct_file_structure.and(have_correct_encoding)
        end

        def et1a_text_file
          raise "Not yet converted to ccd"
          uploaded_file = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] =~ /\Aet1a.*\.txt\z/ }
          raise "No uploaded file starting with 'et1a' and ending in '.txt' has been exported" if uploaded_file.nil?

          EtApi::Test::FileObjects::Et1aTxtFile.new download(uploaded_file)
        end

        def et1_pdf_file(template: 'et1-v6-en')
          document = ccd_case.dig('case_fields', 'documentCollection').find do |entry|
            entry.dig('value', 'typeOfDocument') == 'ET1'
          end
          raise "No ET1 document was exported" if document.nil?

          uploaded_document = document.dig('value', 'uploadedDocument')
          file = download(url: uploaded_document.fetch('document_binary_url'))
          EtApi::Test::FileObjects::Et1PdfFile.new file, template: template, lookup_root: 'claim_pdf_fields'
        end

        def assert_no_secondary_claimants
          expect(ccd_case.dig('case_fields', 'caseType')).to eq('Single')
        end

        def assert_secondary_claimants(claimants)
          raise "Not yet converted to ccd"
          expected_claimants = claimants.map do |claimant|
            include(claimant.except(:address_attributes, :allow_video_attendance, :allow_phone_attendance, :no_phone_or_video_reason, :contact_preference).
              merge(address: a_hash_including(claimant[:address_attributes].to_h), contact_preference: claimant[:contact_preference]&.underscore))
          end
          expect(data.dig(:resource, :secondary_claimants)).to match_array(expected_claimants)
        end

        def assert_no_secondary_respondents
          expect(ccd_case.dig('case_fields', 'respondentCollection').size).to eq(1)
        end

        def assert_secondary_respondents(respondents)
          raise "Not yet converted to ccd"
          expected_respondents = respondents.map do |respondent|
            include(respondent.except(:address_attributes, :work_address_attributes).
              merge(address: a_hash_including(respondent[:address_attributes].to_h), work_address: a_hash_including(respondent[:work_address_attributes].to_h)))
          end
          expect(data.dig(:resource, :secondary_respondents)).to match_array(expected_respondents)
        end

        def assert_no_representatives
          expect(ccd_case.dig('case_fields', 'claimantRepresentedQuestion')).to eq('No')
        end

        def assert_representative(representative)
          raise "Not yet converted to ccd"
          expect(data.dig(:resource, :primary_representative)).to include representative.except(:address_attributes).merge(address: a_hash_including(representative[:address_attributes].to_h))
        end

        def csv_file
          raise "Not yet converted to ccd"
          claimant = data.dig(:resource, :primary_claimant)
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] == "et1a_#{claimant[:first_name]}_#{claimant[:last_name]}.csv" }
          download(file_data)
        end

        def claim_details_file
          raise "Not yet converted to ccd"
          claimant = data.dig(:resource, :primary_claimant)
          file_data = data.dig(:resource, :uploaded_files).detect { |u| u[:filename] == "et1_attachment_#{claimant[:first_name]}_#{claimant[:last_name]}.rtf" }
          download(file_data)
        end

        def assert_claim_details(claim)
          expect(ccd_case.dig('case_fields', 'claimantHearingPreference')).to include(
            "claimant_hearing_panel_preference" => claim[:case_heard_by_preference]&.humanize,
            "claimant_hearing_panel_preference_why" => claim[:case_heard_by_preference_reason]
          )
          expect(ccd_case.dig('case_fields', 'claimantOtherType')).to include(
            "dateOfLastEvent" => claim[:last_event_date]
          )
        end

        private

        attr_accessor :ccd_case

        def acas_exemption_reason(code)
          {
            'joint_claimant_has_acas_number' => 'Another person',
            'acas_has_no_jurisdiction' => 'No Power',
            'employer_contacted_acas' => 'Employer already in touch',
            'interim_relief' => 'Unfair Dismissal'
          }[code]
        end

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

        def initialize(job, use_active_job: Rails.application.config.try(:use_active_job))
          self.job = job
          self.data = if use_active_job
                        JSON.parse(job['arguments'].first, symbolize_names: true)
                      else
                        JSON.parse(job['args'].first, symbolize_names: true)
                      end
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

        def et3_pdf_file(template: 'et3-v4-en')
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
