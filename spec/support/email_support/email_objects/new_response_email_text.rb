require_relative './base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module EmailObjects
      class NewResponseEmailText < Base
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper

        def self.find(repo: ActionMailer::Base.deliveries, reference:)
          instances = repo.map { |delivery| new(delivery) }
          instances.detect { |instance| instance.has_correct_subject? && instance.reference == reference }
        end

        def initialize(*)
          super
          multipart = mail.parts.detect { |p| p.content_type =~ %r{multipart/alternative} }
          part = multipart.parts.detect { |p| p.content_type =~ %r{text/plain} }
          self.body = part.nil? ? '' : part.body.to_s
          self.lines = body.lines.map { |l| l.to_s.strip }
        end

        # The reference number coming from inside the email
        def reference
          reference_line.split(':').last.strip.tr(' which should be quoted on all correspondence.', '')
        end

        def submission_date
          submission_date_line.gsub(/\A.*?:/, '').strip
        end

        def office_address
          office_address_line.split(':').last.strip
        end

        def office_telephone
          office_telephone_line.split(':').last.strip
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail.subject == 'Your Response to Employment Tribunal claim online form receipt'
        end

        def has_correct_to_address_for?(input_data) # rubocop:disable Naming/PredicateName
          mail.to.include?(input_data.email_receipt)
        end

        def office_name
          re = /It has been forwarded to the (.*) office/
          office_name_line.match(re)[1]
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
            expect(submission_date).to eql(now.strftime('%d/%m/%Y')).or(eql((now - 1.minute).strftime('%d/%m/%Y')))
            expect(attached_pdf_for(reference: reference)).to be_present
          end
          true
        end

        private

        def attached_pdf_for(reference:)
          mail.parts.attachments.detect { |a| a.filename == "#{reference}.pdf" }
        end

        def reference_line
          lines.detect { |l| l.starts_with?('This is your reference number:') }
        end

        def office_name_line
          lines.detect { |l| l.starts_with?('Thank you for your submission. It has been forwarded to the ') }
        end

        def office_address_line
          lines.detect { |l| l.starts_with?('Office address:') }
        end

        def office_telephone_line
          lines.detect { |l| l.starts_with?('Telephone:') }
        end

        def submission_date_line
          lines.detect { |l| l.starts_with?('Submission date:') }
        end

        attr_accessor :body, :lines
      end
    end
  end
end
