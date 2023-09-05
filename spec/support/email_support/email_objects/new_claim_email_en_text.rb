require_relative 'base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/claim_helper'
module EtApi
  module Test
    module EmailObjects
      class NewClaimEmailEnText < Base
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::I18n
        include EtApi::Test::ClaimHelper

        def self.find(reference:, repo: ActionMailer::Base.deliveries)
          instances = repo.map { |delivery| new(delivery) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference?(reference) }
        end

        def self.template_reference
          'et1-v1-en'
        end

        def initialize(*args)
          super(*args)
          multipart = mail.parts.detect { |p| p.content_type =~ %r{multipart/alternative} }
          part = multipart.parts.detect { |p| p.content_type =~ %r{text/plain} }
          self.body = part.nil? ? '' : part.body.to_s
          self.lines = body.lines.map { |l| l.to_s.strip }
        end

        def template_reference
          self.class.template_reference
        end

        def has_reference?(reference)
          lines.any? { |l| l.strip == "#{t('claim_email.reference', locale: template_reference)}: #{reference}" }
        end

        def assert_reference(reference)
          raise Capybara::ElementNotFound, "Reference line incorrect for #{reference}" unless has_reference?(reference)
        end

        def has_correct_subject?
          mail.subject == t('claim_email.subject', locale: template_reference)
        end

        def assert_correct_to_address_for?(input_data)
          expect(mail.to).to match_array(input_data.confirmation_email_recipients)
        end

        def has_correct_content_for?(input_data, primary_claimant_data, claimants_file, claim_details_file, reference:)
          office = office_for(case_number: reference)
          aggregate_failures 'validating content' do
            assert_reference(reference)
            expect(has_correct_subject?).to be true
            expect(assert_correct_to_address_for?(input_data)).to be true
            assert_office_information(office)
            assert_submission_date_line
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

        private

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_line?(now.strftime('%d/%m/%Y'))

          assert_submission_date_line((now - 1.minute).strftime('%d/%m/%Y'))
        end

        def assert_claimant(claimant)
          return if lines.any? { |l| l.strip == "#{claimant.first_name} #{claimant.last_name}" }

          raise Capybara::ElementNotFound, "The claimant line was not found for #{claimant.first_name} #{claimant.last_name}"
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

        def reference_line
          lines.detect { |l| l.starts_with?('This is your reference number:') }
        end

        def assert_office_information(office)
          return if lines.any? { |l| l.strip =~ /Tribunal office: \s*#{office.name}, #{office.email}, #{office.telephone}/ }

          raise Capybara::ElementNotFound, "The office information line was not found for #{office.name}"
        end

        def assert_submission_date_line
          now = Time.zone.now
          return if lines.any? do |l|
            l.strip =~ /#{t('claim_email.submission_info', locale: template_reference)}\s*#{t('claim_email.submission_date', date: l(now, format: '%d %B %Y', locale: template_reference.split('-').last), locale: template_reference)}/ ||
            l.strip =~ /#{t('claim_email.submission_info', locale: template_reference)}\s*#{t('claim_email.submission_date', date: l((now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last), locale: template_reference)}/
          end

          raise Capybara::ElementNotFound, "The submission date line was not found"
        end

        def has_submission_date_line?
          assert_submission_date_line
          true
        rescue Capybara::ElementNotFound
          false
        end

        def assert_submission(claimant, claimants_file, claim_details_file)
          expect(lines).to include(t('claim_email.next_steps.well_contact_you', locale: template_reference))
          expect(lines).to include(t('claim_email.next_steps.once_sent_claim', locale: template_reference))
          assert_submission_details(claimant, claimants_file, claim_details_file)
        end

        def assert_submission_details(primary_claimant_data, claimants_file, claim_details_file)
          expect(body).to match(/#{t('claim_email.submission_details', locale: template_reference).upcase}/)
          expect(body).to match(/#{t('claim_email.claim_completed', locale: template_reference)}/)
          expect(body).to match(/#{t('claim_email.see_attached_pdf', locale: template_reference)}/)
          expect(body).to match(/#{t('claim_email.claim_submitted', locale: template_reference)}/)
          if claimants_file.present?
            expect(body).to match(/et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv/)
          else
            expect(body).not_to match(/et1a_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.csv/)
          end

          if claim_details_file.present?
            expect(body).to match(/et1_attachment_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.rtf/)
          else
            expect(body).not_to match(/et1_attachment_#{scrubber primary_claimant_data.first_name}_#{scrubber primary_claimant_data.last_name}.rtf/)
          end
        end

        def scrubber(text)
          text.gsub(/\s/, '_').gsub(/\W/, '')
        end

        attr_accessor :body, :lines
      end
    end
  end
end
