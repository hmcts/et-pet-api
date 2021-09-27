require_relative './base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/claim_helper'
require_relative '../../messaging'
module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class NewClaimEmailEn
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::ClaimHelper
        include EtApi::Test::I18n

        def self.find(repo: GovUkNotifyEmailsSentMonitor.instance.deliveries, reference:)
          instances = repo.map { |mail| new(mail) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }
        end

        def self.count(repo: GovUkNotifyEmailsSentMonitor.instance.deliveries, reference:)
          instances = repo.map { |mail| new(mail) }
          instances.select { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }.length
        end

        def self.template_reference
          'et1-v1-en'
        end

        def initialize(mail)
          self.mail = mail
        end

        def template_reference
          self.class.template_reference
        end

        def has_reference_element?(reference)
          mail.dig('personalisation', 'claim.reference') == reference
        end

        def has_correct_content_for?(input_data, primary_claimant_data, claimants_file, claim_details_file, reference:) # rubocop:disable Naming/PredicateName
          office = office_for(case_number: reference)
          aggregate_failures 'validating content' do
            assert_reference_element(reference)
            expect(has_correct_subject?).to be true
            expect(assert_correct_to_address_for?(input_data)).to be true
            assert_office_information(office)
            assert_submission_date
            assert_claimant(primary_claimant_data)
            expect(attached_pdf_file).to include 'file', 'is_csv'
            if claimants_file.present?
              expect(attached_claimants_file).to match /You successfully uploaded a group claim csv file named .* with your claim\. The file size is .*\./
              expect(mail.dig('personalisation', 'has_claimants_file')).to eql 'yes'
            else
              expect(attached_claimants_file).to eq 'no additional file'
              expect(mail.dig('personalisation', 'has_claimants_file')).to eql 'no'
            end
            if claim_details_file.present?
              expect(attached_info_file).to match /You successfully uploaded an additional document named #{claim_details_file[:filename]} with your claim\. The file size is .*\./
              expect(mail.dig('personalisation', 'has_additional_info')).to eql 'yes'
            else
              expect(attached_info_file).to eq 'no additional file'
              expect(mail.dig('personalisation', 'has_additional_info')).to eql 'no'
            end
          end
          true
        end

        def has_correct_contents_from_db_for?(claim)
          normalized_claim = claim
          has_correct_content_for?(normalized_claim, claim.primary_claimant, claim.uploaded_files.et1_csv.first, claim.uploaded_files.et1_rtf.first, reference: claim.reference)
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail['template_id'] == 'correct-template-id-en'
        end

        private

        def assert_correct_to_address_for?(input_data) # rubocop:disable Naming/PredicateName
          expect(mail['email_address']).to eq(input_data.confirmation_email_recipients.first)
        end

        def assert_reference_element(reference)
          expect(mail.dig('personalisation', 'claim.reference')).to eq reference
        end

        def assert_submission_date_element(submission_date)
          expect(mail.dig('personalisation', 'submitted_date')).to eq t('claim_email.submission_date', locale: template_reference, date: submission_date)
        end

        def has_submission_date_element?(submission_date)
          mail.dig('personalisation', 'submitted_date') == t('claim_email.submission_date', locale: template_reference, date: submission_date)
        end

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_element?(l now, format: '%d %B %Y', locale: template_reference.split('-').last)
          assert_submission_date_element(l (now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last)
        end

        def assert_office_information(office)
          expect(mail['personalisation']).to include 'office.name' => office.name,
                                                     'office.email' => office.email,
                                                     'office.telephone' => office.telephone
        end

        def assert_claimant(primary_claimant_data)
          expect(mail['personalisation']).to include 'primary_claimant.first_name' => primary_claimant_data.first_name,
                                                     'primary_claimant.last_name' => primary_claimant_data.last_name
        end

        def attached_pdf_file
          mail.dig('personalisation', 'link_to_pdf')
        end

        def attached_claimants_file
          mail.dig('personalisation', 'link_to_claimants_file')
        end

        def attached_info_file
          mail.dig('personalisation', 'link_to_additional_info')
        end

        attr_accessor :mail

        def scrubber(text)
          text.gsub(/\s/, '_').gsub(/\W/, '')
        end
      end
    end
  end
end
