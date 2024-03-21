require_relative 'base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/claim_helper'
require_relative '../../messaging'
module EtApi
  module Test
    module EmailObjects
      class NewClaimEmailEnHtml < SitePrism::Page
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::ClaimHelper
        include EtApi::Test::I18n

        def self.find(reference:, repo: ActionMailer::Base.deliveries)
          instances = repo.map { |mail| new(mail) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }
        end

        def self.template_reference
          'et1-v1-en'
        end

        def initialize(mail)
          self.mail = mail
          multipart = mail.parts.detect { |p| p.content_type =~ %r{multipart/alternative} }
          part = multipart.parts.detect { |p| p.content_type =~ %r{text/html} }
          body = part.nil? ? '' : part.body.to_s
          load(body)
          super()
        end

        def template_reference
          self.class.template_reference
        end

        def has_reference_element?(reference)
          claim_number.value?(text: reference)
        end

        def has_correct_content_for?(input_data, primary_claimant_data, claimants_file, claim_details_file, reference:)
          office = office_for(case_number: reference)
          aggregate_failures 'validating content' do
            assert_reference_element(reference)
            expect(has_correct_subject?).to be true
            expect(assert_correct_to_address_for?(input_data)).to be true
            assert_office_information(office)
            assert_submission_date
            assert_claimant(primary_claimant_data)
            assert_submission(primary_claimant_data, claimants_file, claim_details_file)
            expect(attached_pdf_for(primary_claimant_data: primary_claimant_data)).to be_present
            if claimants_file.present?
              expect(attached_claimants_file_for(primary_claimant_data: primary_claimant_data)).to be_present
            else
              expect(attached_claimants_file_for(primary_claimant_data: primary_claimant_data)).not_to be_present
            end
            if claim_details_file.present?
              expect(attached_info_file_for(primary_claimant_data: primary_claimant_data)).to be_present
            else
              expect(attached_info_file_for(primary_claimant_data: primary_claimant_data)).not_to be_present
            end
          end
          true
        end

        def has_correct_subject?
          mail.subject == t('claim_email.subject', locale: template_reference)
        end

        private

        def self.define_site_prism_elements(template_reference)
          section(:claim_number, :xpath, XPath.generate { |x| x.descendant(:td)[x.child(:p)[x.string.n.is(t('claim_email.reference', locale: template_reference))]] }) do
            element(:value, :xpath, XPath.generate { |x| x.child(:p)[2] })
          end

          section(:submission_info, :xpath, XPath.generate { |x| x.descendant(:tr)[x.child(:td)[x.child(:p)[x.string.n.is(t('claim_email.submission_info', locale: template_reference))]]] }) do
            element(:submission_date, :xpath, XPath.generate { |x| x.child(:td)[2].child(:p) })
          end

          section(:office_information, :xpath, XPath.generate { |x| x.descendant(:tr)[x.child(:td)[x.child(:p)[x.string.n.is(t('claim_email.tribunal_office', locale: template_reference))]]] }) do
            element(:office_summary, :xpath, XPath.generate { |x| x.child(:td)[2].child(:p) })
          end

          element(:claimant_full_name, :xpath, XPath.generate { |x| x.descendant(:tr).child(:td)[1].child(:p) })

          section(:submission, :xpath, XPath.generate { |x| x.descendant(:tr)[x.child(:td)[1][x.child(:p)[x.string.n.is(t('claim_email.thank_you', locale: template_reference))]]] }) do
            section(:what_happens_next, :xpath, XPath.generate { |x| x.child(:td)[1] }) do
              include RSpec::Matchers
              include EtApi::Test::I18n
              def assert_valid(template_reference:) # rubocop:disable Lint/NestedMethodDefinition
                expect(root_element).to have_content(t('claim_email.next_steps.well_contact_you', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.next_steps.once_sent_claim', locale: template_reference))
              end
            end

            section(:submission_details, :xpath, XPath.generate { |x| x.child(:td)[1] }) do
              include RSpec::Matchers
              include EtApi::Test::I18n

              def assert_valid(primary_claimant_data, claimants_file, claim_details_file, template_reference:) # rubocop:disable Lint/NestedMethodDefinition
                expect(root_element).to have_content(t('claim_email.submission_details', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.claim_completed', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.see_attached_pdf', locale: template_reference))
                expect(root_element).to have_content(t('claim_email.claim_submitted', locale: template_reference))
                now = Time.zone.now
                expect(root_element).to have_content(t('claim_email.submitted_at', date: l(now, format: '%d %B %Y', locale: template_reference.split('-').last), locale: template_reference)).or have_content(t('claim_email.submitted_at', date: l((now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last), locale: template_reference))
                if claimants_file.present?
                  expect(root_element).to have_content "et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv"
                else
                  expect(root_element).to have_no_content "et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv"
                end

                if claim_details_file.present?
                  expect(root_element).to have_content("et1_attachment_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.rtf")
                else
                  expect(root_element).to have_no_content("et1_attachment_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.rtf")
                end
              end

              private

              def scrubber(text) # rubocop:disable Lint/NestedMethodDefinition
                text.gsub(/\s/, '_').gsub(/\W/, '')
              end
            end

          end
        end

        private_class_method :define_site_prism_elements

        define_site_prism_elements(template_reference)

        def assert_correct_to_address_for?(input_data)
          expect(mail.to).to match_array(input_data.confirmation_email_recipients)
        end

        def assert_reference_element(reference)
          expect(claim_number).to have_value(text: reference)
        end

        def assert_submission_date_element(submission_date)
          expect(submission_info).to have_submission_date(text: t('claim_email.submission_date', locale: template_reference, date: submission_date))
        end

        def has_submission_date_element?(submission_date)
          submission_info.has_submission_date?(text: t('claim_email.submission_date', locale: template_reference, date: submission_date))
        end

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_element?(l(now, format: '%d %B %Y', locale: template_reference.split('-').last))

          assert_submission_date_element(l((now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last))
        end

        def assert_office_information(office)
          expect(office_information).to have_office_summary(text: "#{office.name}, #{office.email}, #{office.telephone}")
        end

        def assert_claimant(primary_claimant_data)
          expect(self).to have_claimant_full_name(text: "#{primary_claimant_data.first_name} #{primary_claimant_data.last_name}")
        end

        def assert_submission(claimant, claimants_file, claim_details_file)
          expect(submission).to have_what_happens_next
          submission.what_happens_next.assert_valid(template_reference: template_reference)
          submission.submission_details.assert_valid(claimant, claimants_file, claim_details_file, template_reference: template_reference)
        end

        def attached_pdf_for(primary_claimant_data:)
          mail.parts.attachments.detect { |a| a.filename == "et1_#{scrubber primary_claimant_data.first_name.downcase}_#{scrubber primary_claimant_data.last_name.downcase}.pdf" }
        end

        def attached_claimants_file_for(primary_claimant_data:)
          mail.parts.attachments.detect { |a| a.filename == "et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv" }
        end

        def attached_info_file_for(primary_claimant_data:) # rubocop:disable Lint/UnusedMethodArgument
          mail.parts.attachments.detect { |a| a.filename.end_with? '.rtf' }
        end

        attr_accessor :mail

        def scrubber(text)
          text.gsub(/\s/, '_').gsub(/\W/, '')
        end
      end
    end
  end
end
