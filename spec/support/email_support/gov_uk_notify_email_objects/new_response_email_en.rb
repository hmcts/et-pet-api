require_relative 'base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/response_helper'
require_relative '../../messaging'
module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class NewResponseEmailEn < SitePrism::Page
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::ResponseHelper
        include EtApi::Test::I18n

        def self.find(reference:, repo: GovUkNotifyEmailsSentMonitor.instance.deliveries)
          instances = repo.map { |mail| new(mail) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }
        end

        def self.count(reference:, repo: GovUkNotifyEmailsSentMonitor.instance.deliveries)
          instances = repo.map { |mail| new(mail) }
          instances.select { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }.length
        end

        def self.template_reference
          'et3-v2-en'
        end

        def initialize(mail)
          self.mail = mail
          load mail.body
          super()
        end

        def template_reference
          self.class.template_reference
        end

        def has_reference_element?(reference)
          response_number.value == reference
        end

        def has_correct_content_for?(input_data, reference:)
          office = office_for(case_number: reference)
          aggregate_failures 'validating content' do
            assert_reference_element(reference)
            expect(has_correct_subject?).to be true
            expect(assert_correct_to_address_for?(input_data)).to be true
            assert_office_information(office)
            assert_submission_date
          end
          true
        end

        def has_correct_contents_from_db_for?(response)
          normalized_response = response
          has_correct_content_for?(normalized_response, reference: response.reference)
        end

        def has_correct_subject?
          mail.subject == t('claim_email.subject', locale: self.class.template_reference)
        end

        private

        def assert_correct_to_address_for?(input_data)
          expect(mail.email_address).to eq(input_data.email_receipt)
        end

        def assert_reference_element(reference)
          expect(response_number.value).to eq reference
        end

        def assert_submission_date_element(expected_submission_date)
          expect(submission_date.value).to eq t('claim_email.submitted_at', locale: template_reference, date: expected_submission_date)
        end

        def has_submission_date_element?(expected_submission_date)
          submission_date.value == t('claim_email.submission_date', locale: template_reference, date: expected_submission_date)
        end

        def assert_submission_date
          now = Time.zone.now

          return if has_submission_date_element?(l(now, format: '%d %B %Y', locale: template_reference.split('-').last))

          assert_submission_date_element(l((now - 1.minute), format: '%d %B %Y', locale: template_reference.split('-').last))
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
          section(:response_number, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with(t('claim_email.reference', locale: template_reference))] }) do
            include EtApi::Test::I18n
            define_method :value do
              root_element.text.gsub(/#{t('claim_email.reference', locale: template_reference)}/, '').strip
            end
          end

          section(:submission_date, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with(t('claim_email.submission_info', locale: template_reference))] }) do
            include EtApi::Test::I18n
            define_method :value do
              root_element.text.gsub(/#{t('claim_email.submission_info', locale: template_reference)}/, '').strip
            end
          end
        end

        private_class_method :define_site_prism_elements

        define_site_prism_elements(template_reference)

      end
    end
  end
end
