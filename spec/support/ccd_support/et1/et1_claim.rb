module EtApi
  module Test
    module Ccd
      class Et1Claim
        def initialize(interface:, reference:)
          self.interface = interface
          self.reference = reference
        end

        private

        def get_claim_data
          RestClient.get("http://fakeccd.com/caseworkers/#{interface.user_id}/jurisdictions/#{interface.jurisdiction_id}/case-types/#{interface.case_type_id}/cases?case.feeGroupReference=#{reference}")
        end

        attr_accessor :interface, :reference
      end
    end
  end
end
