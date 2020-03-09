require_relative './base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module EmailObjects
      class NewFeedbackEmailText < SitePrism::Page
        include RSpec::Matchers
        include EtApi::Test::OfficeHelper
        include EtApi::Test::I18n

        def self.find(repo: ActionMailer::Base.deliveries, email_address:, template_reference:)
          instances = repo.map { |mail| NewFeedbackEmailText.new(mail, template_reference: template_reference) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_correct_email_address?(email_address) && instance.has_valid_email_headers?(email_address) }
        end

        def initialize(mail, template_reference:)
          self.mail = mail
          self.template_reference = template_reference
          part = mail.parts.detect { |p| p.content_type =~ %r{text\/plain} }
          self.body = part.nil? ? '' : part.body.to_s
          self.lines = body.lines.map { |l| l.to_s.strip }
        end

        def has_correct_subject?
          mail.subject == 'Your feedback to Employment Tribunal'
        end

        def has_correct_email_address?(expected_email_address)
          lines.include?("Email address: #{expected_email_address}")
        end

        def has_correct_content_for?(input_data)
          has_correct_problems_for?(input_data) && has_correct_suggestions_for?(input_data)
        end

        def has_valid_email_headers?(email_address)
          mail.to.include?("fake@servicenow.fake.com") && mail.from.include?(email_address)
        end

        private

        def has_correct_problems_for?(input_data)
          lines.include?("Problems: #{input_data.problems}")
        end

        def has_correct_suggestions_for?(input_data)
          lines.include?("Suggestions: #{input_data.suggestions}")
        end

        attr_accessor :mail, :template_reference, :body, :lines
      end
    end
  end
end
