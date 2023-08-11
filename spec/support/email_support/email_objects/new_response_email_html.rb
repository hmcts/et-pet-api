require_relative './base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module EmailObjects
      class NewResponseEmailHtml < SitePrism::Page
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::I18n

        def self.find(reference:, template_reference:, repo: ActionMailer::Base.deliveries)
          instances = repo.map { |mail| NewResponseEmailHtml.new(mail, template_reference: template_reference) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }
        end

        def initialize(mail, template_reference:)
          self.mail = mail
          self.template_reference = template_reference
          multipart = mail.parts.detect { |p| p.content_type =~ %r{multipart/alternative} }
          part = multipart.parts.detect { |p| p.content_type =~ %r{text/html} }
          body = part.nil? ? '' : part.body.to_s
          load(body)
        end

        def has_reference_element?(reference)
          assert_reference_element(reference)
          true
        rescue Capybara::ElementNotFound
          false
        end

        def has_correct_content_for?(input_data, reference:) # rubocop:disable Naming/PredicateName
          office = office_for(case_number: input_data.case_number)
          aggregate_failures 'validating content' do
            assert_reference_element(reference)
            expect(has_correct_subject?).to be true
            expect(has_correct_to_address_for?(input_data)).to be true
            assert_office_name_element(office.name)
            assert_office_address_element(office.address)
            assert_office_telephone_element(office.telephone)
            assert_submission_date
            expect(attached_pdf_for(reference: reference)).to be_present
          end
          true
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail.subject == t('response_email.subject', locale: template_reference)
        end

        private

        def has_correct_to_address_for?(input_data) # rubocop:disable Naming/PredicateName
          mail.to.include?(input_data.email_receipt)
        end

        def assert_reference_element(reference)
          assert_selector(:css, 'p', text: t('response_email.reference', locale: template_reference, reference: reference), wait: 0)
        end

        def assert_submission_date_element(submission_date)
          assert_selector(:css, 'p', text: t('response_email.submission_date', locale: template_reference, submission_date: submission_date))
        end

        def has_submission_date_element?(submission_date)
          assert_submission_date_element(submission_date)
          true
        rescue Capybara::ElementNotFound
          false
        end

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_element?(now.strftime('%d/%m/%Y'))

          assert_submission_date_element((now - 1.minute).strftime('%d/%m/%Y'))
        end

        def assert_office_address_element(office_address)
          assert_selector(:css, 'p', text: t('response_email.office_address', locale: template_reference, address: office_address), wait: 0)
        end

        def assert_office_telephone_element(telephone)
          assert_selector(:css, 'p', text: t('response_email.office_telephone', locale: template_reference, telephone: telephone), wait: 0)
        end

        def assert_office_name_element(office_name)
          assert_selector(:css, 'p', text: t('response_email.office_name', locale: template_reference, office_name: office_name), wait: 0)
        end

        def attached_pdf_for(reference:)
          mail.parts.attachments.detect { |a| a.filename == "#{reference}.pdf" }
        end

        attr_accessor :mail, :template_reference
      end
    end
  end
end
