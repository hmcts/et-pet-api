require_relative './base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module EmailObjects
      class NewResponseEmailText < Base
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::I18n

        def self.find(reference:, template_reference:, repo: ActionMailer::Base.deliveries)
          instances = repo.map { |delivery| new(delivery, template_reference: template_reference) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference?(reference) }
        end

        def initialize(*args, template_reference:)
          super(*args)
          multipart = mail.parts.detect { |p| p.content_type =~ %r{multipart/alternative} }
          part = multipart.parts.detect { |p| p.content_type =~ %r{text/plain} }
          self.body = part.nil? ? '' : part.body.to_s
          self.lines = body.lines.map { |l| l.to_s.strip }
          self.template_reference = template_reference
        end

        def has_reference?(reference)
          lines.any? { |l| l.strip == t('response_email.reference', locale: template_reference, reference: reference) }
        end

        def assert_reference(reference)
          raise Capybara::ElementNotFound, "Reference line incorrect for #{reference}" unless has_reference?(reference)
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail.subject == t('response_email.subject', locale: template_reference)
        end

        def has_correct_to_address_for?(input_data) # rubocop:disable Naming/PredicateName
          mail.to.include?(input_data.email_receipt)
        end

        def has_correct_content_for?(input_data, reference:) # rubocop:disable Naming/PredicateName
          office = office_for(case_number: input_data.case_number)
          aggregate_failures 'validating content' do
            assert_reference(reference)
            expect(has_correct_subject?).to be true
            expect(has_correct_to_address_for?(input_data)).to be true
            assert_office_name(office.name)
            assert_office_address(office.address)
            assert_office_telephone(office.telephone)
            assert_submission_date
            expect(attached_pdf_for(reference: reference)).to be_present
          end
          true
        end

        private

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_line?(now.strftime('%d/%m/%Y'))

          assert_submission_date_line((now - 1.minute).strftime('%d/%m/%Y'))
        end

        def attached_pdf_for(reference:)
          mail.parts.attachments.detect { |a| a.filename == "#{reference}.pdf" }
        end

        def reference_line
          lines.detect { |l| l.starts_with?('This is your reference number:') }
        end

        def assert_office_name(office_name)
          return if lines.any? { |l| l.strip == t('response_email.office_name', office_name: office_name, locale: template_reference) }

          raise Capybara::ElementNotFound, "The office name line was not found for #{office_name}"
        end

        def assert_office_address(office_address)
          return if lines.any? { |l| l.strip == t('response_email.office_address', address: office_address, locale: template_reference) }

          raise Capybara::ElementNotFound, "The office address line was not found for #{office_address}"
        end

        def assert_office_telephone(telephone)
          return if lines.any? { |l| l.strip == t('response_email.office_telephone', telephone: telephone, locale: template_reference) }

          raise Capybara::ElementNotFound, "The office telephone line was not found for #{telephone}"
        end

        def assert_submission_date_line(submission_date)
          return if lines.any? { |l| l.strip == t('response_email.submission_date', submission_date: submission_date, locale: template_reference) }

          raise Capybara::ElementNotFound, "The submission date line was not found for #{submission_date}"
        end

        def has_submission_date_line?(submission_date)
          assert_submission_date_line(submission_date)
          true
        rescue Capybara::ElementNotFound
          false
        end

        attr_accessor :body, :lines, :template_reference
      end
    end
  end
end
