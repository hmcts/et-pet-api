module EtApi
  module Test
    module ResponseHelper
      def response_submission_reference_for(reference:)
        Response.where(reference: reference).first&.submission_reference
      end

    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::ResponseHelper
end
