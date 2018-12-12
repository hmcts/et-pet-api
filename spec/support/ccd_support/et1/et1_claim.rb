module EtApi
  module Test
    module Ccd
      class Et1Claim
        include RSpec::Matchers
        def initialize(interface:, reference:)
          self.interface = interface
          self.reference = reference
        end

        def has_claimant_for?(claimant)
            get_claims_data
            return false if claims_data.empty?
            data = claims_data.last.dig('case_data', 'claimantType')
            expect(data).to eql(claimant)
        end

        private

        def get_claims_data
          self.claims_data = JSON.parse RestClient.get("http://fakeccd.com/caseworkers/#{interface.user_id}/jurisdictions/#{interface.jurisdiction_id}/case-types/#{interface.case_type_id}/cases?case.feeGroupReference=#{reference}").body
        end

        attr_accessor :interface, :reference, :claims_data
      end
    end
  end
end
