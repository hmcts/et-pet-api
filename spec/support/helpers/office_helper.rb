module EtApi
  module Test
    module OfficeHelper
      def office_for(case_number:)
        office_code = case_number[0..1].to_i
        Office.where(code: office_code).first
      end

    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::OfficeHelper
end
