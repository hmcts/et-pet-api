module EtApi
  module Test
    class EmailsSent
      def initialize(deliveries: ActionMailer::Base.deliveries)
        self.deliveries = deliveries
      end

      def new_response_html_email_for(reference:, template_reference:)
        EtApi::Test::EmailObjects::NewResponseEmailHtml.find(reference: reference, template_reference: template_reference)
      end

      def new_response_text_email_for(reference:, template_reference:)
        EtApi::Test::EmailObjects::NewResponseEmailText.find(reference: reference, template_reference: template_reference)
      end

      private

      attr_accessor :deliveries
    end
  end
end
