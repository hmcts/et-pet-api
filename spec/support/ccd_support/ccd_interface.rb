require 'webmock'
require 'addressable'
require 'et_fake_ccd_server'
require_relative './et1/et1_claim'
module EtApi
  module Test
    module Ccd
      class Interface
        def initialize(
          initiate_case_url:,
          idam_user_token_exchange_url:,
          idam_service_token_exchange_url:,
          create_case_url:,
          user_id:,
          user_role: 'caseworker-publiclaw',
          jurisdiction_id: 'PUBLICLAW',
          case_type_id: 'TRIB_MVP_3_TYPE',
          initiate_case_event_id: 'initiateCase'
        )
          self.idam_user_token_exchange_url = idam_user_token_exchange_url
          self.idam_service_token_exchange_url = idam_service_token_exchange_url
          self.create_case_url = create_case_url
          self.user_id = user_id
          self.user_role = user_role
          self.jurisdiction_id = jurisdiction_id
          self.case_type_id = case_type_id
          self.initiate_case_event_id = initiate_case_event_id
          self.initiate_case_url = initiate_case_url
          init_stubs
        end

        def et1_claim(reference:)
          ::EtApi::Test::Ccd::Et1Claim.new(reference: reference, interface: self)
        end

        private

        attr_accessor :idam_user_token_exchange_url, :idam_service_token_exchange_url, :create_case_url
        attr_accessor :user_role, :user_id, :jurisdiction_id, :case_type_id, :initiate_case_event_id, :initiate_case_url

        def init_stubs
          WebMock.stub_request(:any, /fakeccd\.com/).to_rack(EtFakeCcdServer::Server)
        end
      end
    end
  end
end
