require_relative './base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module EmailObjects
      class NewResponseEmailHtml < SitePrism::Page
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        element(:reference_element, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with('This is your reference number:')] })
        element(:submission_date_element, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with('Submission date:')] })
        element(:office_address_element, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with('Office address:')] })
        element(:office_telephone_element, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with('Telephone:')] })
        element(:office_name_element, :xpath, XPath.generate { |x| x.descendant(:p)[x.string.n.starts_with('Thank you for your submission. It has been forwarded to the')] })

        def self.find(repo: ActionMailer::Base.deliveries, reference:)
          instances = repo.map { |mail| NewResponseEmailHtml.new(mail) }
          instances.detect { |instance| instance.has_correct_subject? && instance.reference == reference }
        end

        def initialize(mail)
          self.mail = mail
          multipart = mail.parts.detect { |p| p.content_type =~ %r{multipart\/alternative} }
          part = multipart.parts.detect { |p| p.content_type =~ %r{text\/html} }
          body = part.nil? ? '' : part.body.to_s
          load(body)
        end

        # The reference number coming from inside the email
        def reference
          reference_element.text.split(':').last.strip.tr(' which should be quoted on all correspondence.', '')
        end

        def submission_date
          submission_date_element.text.gsub(/\A.*?:/, '').strip
        end

        def office_address
          office_address_element.text.split(':').last.strip
        end

        def office_telephone
          office_telephone_element.text.split(':').last.strip
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail.subject == 'Your Response to Employment Tribunal claim online form receipt'
        end

        def has_correct_to_address_for?(input_data) # rubocop:disable Naming/PredicateName
          mail.to.include?(input_data.email_receipt)
        end

        def office_name
          re = /It has been forwarded to the (.*) office/
          office_name_element.text.match(re)[1]
        end

        def has_correct_content_for?(input_data, reference:) # rubocop:disable Naming/PredicateName
          office = office_for(case_number: input_data.case_number)
          aggregate_failures 'validating content' do
            expect(self.reference).to eql reference
            expect(has_correct_subject?).to be true
            expect(has_correct_to_address_for?(input_data)).to be true
            expect(office_name).to eql office.name
            expect(office_address).to eql office.address
            expect(office_telephone).to eql office.telephone
            now = Time.zone.now
            expect(submission_date).to eql(now.strftime('%d/%m/%Y %H:%M')).or(eql((now - 1.minute).strftime('%d/%m/%Y %H:%M')))
            expect(attached_pdf_for(reference: reference)).to be_present
          end
          true
        end

        private

        def attached_pdf_for(reference:)
          mail.parts.attachments.detect { |a| a.filename == "#{reference}.pdf" }
        end

        attr_accessor :mail
      end
    end
  end
end
