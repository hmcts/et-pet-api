module EtApi
  module Test
    class EmailsSent
      def initialize(deliveries: ActionMailer::Base.deliveries)
        self.deliveries = deliveries
      end

      def empty?
        deliveries.empty?
      end

      def new_response_html_email_for(reference:, template_reference:)
        email = EtApi::Test::EmailObjects::NewResponseEmailHtml.find(reference: reference, template_reference: template_reference)
        raise "No HTML response (ET3) email has been sent for reference #{reference} using template reference #{template_reference}" unless email.present?
        email
      end

      def new_response_text_email_for(reference:, template_reference:)
        email = EtApi::Test::EmailObjects::NewResponseEmailText.find(reference: reference, template_reference: template_reference)
        raise "No text response (ET3) email has been sent for reference #{reference} using template reference #{template_reference}" unless email.present?
        email
      end

      def new_claim_html_email_for(reference:, template_reference:)
        email = case template_reference
                when /\-en\z/ then EtApi::Test::EmailObjects::NewClaimEmailEnHtml.find(reference: reference)
                when /\-cy\z/ then EtApi::Test::EmailObjects::NewClaimEmailCyHtml.find(reference: reference)
                else raise "Unknown template reference #{template_reference}"
        end
        raise "No HTML claim (ET1) email has been sent for reference #{reference} using template reference #{template_reference}" unless email.present?
        email
      end

      def new_claim_text_email_for(reference:, template_reference:)
        email = case template_reference
                when /\-en\z/ then EtApi::Test::EmailObjects::NewClaimEmailEnText.find(reference: reference)
                when /\-cy\z/ then EtApi::Test::EmailObjects::NewClaimEmailCyText.find(reference: reference)
                else raise "Unknown template reference #{template_reference}"
                end
        raise "No text claim (ET1) email has been sent for reference #{reference} using template reference #{template_reference}" unless email.present?
        email
      end

      private

      attr_accessor :deliveries
    end
  end
end
