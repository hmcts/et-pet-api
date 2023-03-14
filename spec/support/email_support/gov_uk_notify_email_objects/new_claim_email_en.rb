require_relative './base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/claim_helper'
require_relative '../../messaging'
module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class NewClaimEmailEn < SitePrism::Page
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
          load mail.body
        end

        def template_reference
          self.class.template_reference
        end

        def has_reference_element?(reference)
          claim_number.value == reference
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
            expect(attached_pdf_file.value).to be_present
            if claimants_file.present?
              expect(attached_claimants_file.value).to match /You successfully uploaded a group claim csv file named .* with your claim\. The file size is .*\./
            else
              expect(attached_claimants_file.value).to eq 'no additional file'
            end
            if claim_details_file.present?
              expect(attached_info_file.value).to match(/You successfully uploaded an additional document named #{claim_details_file[:filename]} with your claim\. The file size is .*\./)
            else
              expect(attached_info_file.value).to eq 'no additional file'
            end
          end
          true
        end

        def has_correct_contents_from_db_for?(claim)
          normalized_claim = claim
          has_correct_content_for?(normalized_claim, claim.primary_claimant, claim.uploaded_files.et1_csv.first, claim.uploaded_files.et1_claim_details.first, reference: claim.reference)
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail.subject == t('claim_email.subject', locale: self.class.template_reference)
        end

        private

        def assert_correct_to_address_for?(input_data) # rubocop:disable Naming/PredicateName
          expect(mail.email_address).to eq(input_data.confirmation_email_recipients.first)
        end

        def assert_reference_element(reference)
          expect(claim_number.value).to eq reference
        end

        def assert_submission_date_element(expected_submission_date)
          expect(submission_date.value).to eq t('claim_email.submitted_at', locale: template_reference, date: expected_submission_date)
        end

        def has_submission_date_element?(expected_submission_date)
          submission_date.value == t('claim_email.submission_date', locale: template_reference, date: expected_submission_date)
        end

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_element?(l now, format: '%d %B %Y', locale: template_reference.split('-').last)
          assert_submission_date_element(l (now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last)
        end

        def assert_office_information(office)
          expect(tribunal_office.value).to eql office.name
          expect(tribunal_office_contact.email_value).to eql office.email
          expect(tribunal_office_contact.telephone_value).to eql office.telephone
        end

        def assert_claimant(primary_claimant_data)
          expect(page).to have_content("#{primary_claimant_data.first_name} #{primary_claimant_data.last_name}")
        end

        attr_accessor :mail

        def scrubber(text)
          text.gsub(/\s/, '_').gsub(/\W/, '')
        end

        def self.define_site_prism_elements(template_reference)
          section :claim_number, :xpath, XPath.generate {|x| x.descendant(:p)[x.string.n.starts_with(t('claim_email.reference', locale: template_reference))]} do
            include EtApi::Test::I18n
            define_method :value do
              root_element.text.gsub(%r(#{t('claim_email.reference', locale: template_reference)}), '').strip
            end
          end

          section :submission_date, :xpath, XPath.generate {|x| x.descendant(:p)[x.string.n.starts_with(t('claim_email.submission_info', locale: template_reference))]} do
            include EtApi::Test::I18n
            define_method :value do
              root_element.text.gsub(%r(#{t('claim_email.submission_info', locale: template_reference)}), '').strip
            end
          end

          section :tribunal_office, :xpath, XPath.generate {|x| x.descendant(:p)[x.string.n.starts_with(t('claim_email.tribunal_office', locale: template_reference))] } do
            include EtApi::Test::I18n
            define_method :value do
              root_element.text.gsub(%r(#{t('claim_email.tribunal_office', locale: template_reference)}), '').strip
            end
          end

          section :tribunal_office_contact, :xpath, XPath.generate {|x| x.descendant(:p)[x.string.n.starts_with(t('claim_email.tribunal_office_contact', locale: template_reference))] } do
            include EtApi::Test::I18n
            define_method :value do
              root_element.text.gsub(%r(#{t('claim_email.tribunal_office_contact', locale: template_reference)}), '').strip
            end
            def email_value
              value.split(', ').first
            end

            def telephone_value
              value.split(', ').last
            end
          end

          section :attached_pdf_file, :xpath, XPath.generate { |x| x.descendant(:p)[x.preceding_sibling(:p)[1][x.string.n.starts_with(t('claim_email.see_attached_pdf', locale: template_reference))]] } do
            def value
              text.strip
            end
          end

          section :attached_claimants_file, :xpath, XPath.generate { |x| x.descendant(:p)[x.preceding_sibling(:p)[2][x.string.n.starts_with(t('claim_email.group_claim_file', locale: template_reference))]] } do
            def value
              text.strip
            end
          end

          section :attached_info_file, :xpath, XPath.generate { |x| x.descendant(:p)[x.preceding_sibling(:p)[2][x.string.n.starts_with(t('claim_email.additional_information_file.label', locale: template_reference))]] } do
            def value
              text.strip
            end
          end

          element :claimant_full_name, :xpath, XPath.generate {|x| x.descendant(:tr).child(:td)[1].child(:p)}

          section :submission, :xpath, XPath.generate {|x| x.descendant(:tr)[x.child(:td)[1][x.child(:p)[x.string.n.is(t('claim_email.thank_you', locale: template_reference))]]]} do
            section :what_happens_next, :xpath, XPath.generate {|x| x.child(:td)[1]} do
              include RSpec::Matchers
              include EtApi::Test::I18n
              def assert_valid(template_reference:)
                expect(root_element).to have_content(t('claim_email.next_steps.well_contact_you', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.next_steps.once_sent_claim', locale: template_reference))
              end
            end

            section :submission_details, :xpath, XPath.generate {|x| x.child(:td)[1]} do
              include RSpec::Matchers
              include EtApi::Test::I18n

              def assert_valid(primary_claimant_data, claimants_file, claim_details_file, template_reference:)
                expect(root_element).to have_content(t('claim_email.submission_details', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.claim_completed', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.see_attached_pdf', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.claim_submitted', locale: template_reference))
                now = Time.now
                expect(root_element).to have_content(t('claim_email.submitted_at', date: l(now, format: '%d %B %Y', locale: template_reference.split('-').last), locale: template_reference)).or have_content(t('claim_email.submitted_at', date: l((now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last), locale: template_reference))
                if claimants_file.present?
                  expect(root_element).to have_content "et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv"
                else
                  expect(root_element).not_to have_content "et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv"
                end

                if claim_details_file.present?
                  expect(root_element).to have_content("et1_attachment_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.rtf")
                else
                  expect(root_element).not_to have_content("et1_attachment_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.rtf")
                end
              end

              private

              def scrubber(text)
                text.gsub(/\s/, '_').gsub(/\W/, '')
              end
            end


          end
        end

        define_site_prism_elements(template_reference)

      end
    end
  end
end
