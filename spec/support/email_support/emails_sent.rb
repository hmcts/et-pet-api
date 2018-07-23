module EtApi
  module Test
    class EmailsSent
      def initialize(deliveries: ActionMailer::Base.deliveries)
        self.deliveries = deliveries
      end

      def new_response_html_email_for(reference:)
        EtApi::Test::EmailObjects::NewResponseEmailHtml.find(reference: reference)
      end

      def new_response_text_email_for(reference:)
        EtApi::Test::EmailObjects::NewResponseEmailText.find(reference: reference)
      end

      private

      attr_accessor :deliveries
    end
  end
end
