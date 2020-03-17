module EtApi
  module Test
    module ClaimHelper
      def claim_submission_reference_for(reference:)
        Claim.where(reference: reference).first&.submission_reference
      end

    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::OfficeHelper
end
