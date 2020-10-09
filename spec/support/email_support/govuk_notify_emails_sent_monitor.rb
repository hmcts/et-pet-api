require 'sinatra/base'

module EtApi
  module Test
    class GovUkNotifyEmailsSentMonitor
      include Singleton

      attr_reader :deliveries

      def start
        deliveries.clear
        WebMock.stub_request(:any, /https:\/\/api\.notifications\.service\.gov\.uk/).to_rack(RackHandler.new(deliveries))
        self
      end

      def empty?
        deliveries.empty?
      end

      def new_claim_email_for(reference:, template_reference:)
        email = case template_reference
                when /\-en\z/ then
                  EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailEn.find(reference: reference)
                when /\-cy\z/ then
                  EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailCy.find(reference: reference)
                else
                  raise "Unknown template reference #{template_reference}"
                end
        raise "No govuk notify claim (ET1) email has been sent for reference #{reference} using template reference #{template_reference}" unless email.present?
        email
      end

      def new_claim_email_count_for(reference:, template_reference:)
        case template_reference
        when /\-en\z/ then
          EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailEn.count(reference: reference)
        when /\-cy\z/ then
          EtApi::Test::GovUkNotifyEmailObjects::NewClaimEmailCy.count(reference: reference)
        else
          raise "Unknown template reference #{template_reference}"
        end
      end

      private

      def initialize(*)
        @deliveries = []
      end

      class RackHandler < Sinatra::Application
        def initialize(deliveries)
          super()
          @deliveries = deliveries
        end

        get '/v2/templates' do |*args|
          content_type 'application/json'
          {
            templates: [
              {
                id: 'correct-template-id-en',
                name: 'et1-confirmation-email-v1-en'
              },
              {
                id: 'correct-template-id-cy',
                name: 'et1-confirmation-email-v1-cy'
              }
            ]
          }.to_json
        end

        post '/v2/notifications/email' do
          data = JSON.parse request.body.read
          deliveries << data
          {
            id: 'response-id',
            reference: 'valid-reference',
            content: 'Any old content will do',
            template: {

            },
            uri: 'https://fake.com/callback'
          }.to_json
        end

        private

        attr_reader :deliveries

      end
    end
  end
end
