require 'sinatra/base'

module EtApi
  module Test
    class GovUkNotifyEmailsSentMonitor
      include Singleton

      def start
        WebMock.stub_request(:any, %r{https://api\.notifications\.service\.gov\.uk}).to_rack(GovFakeNotify::RootApp)
        self
      end

      def deliveries(config: Rails.application.config.govuk_notify)
        api_key = config["#{config.mode}_api_key"]
        args = []
        args << config.custom_url unless config.custom_url == false
        client = Notifications::Client.new(api_key, *args)
        client.get_notifications(template_type: :email).collection
      end

      delegate :empty?, to: :deliveries

      def new_claim_email_for(reference:, template_reference:)
        email = case template_reference
                when /-en\z/
                  EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailEn.find(reference: reference)
                when /-cy\z/
                  EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailCy.find(reference: reference)
                else
                  raise "Unknown template reference #{template_reference}"
                end
        raise "No govuk notify claim (ET1) email has been sent for reference #{reference} using template reference #{template_reference}\n\n#{GovUkNotifyEmailsSentMonitor.instance.deliveries}" if email.blank?

        email
      end

      def new_claim_email_count_for(reference:, template_reference:)
        case template_reference
        when /-en\z/
          EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailEn.count(reference: reference)
        when /-cy\z/
          EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailCy.count(reference: reference)
        else
          raise "Unknown template reference #{template_reference}"
        end
      end
    end
  end
end
