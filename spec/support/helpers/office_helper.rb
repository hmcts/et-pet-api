module EtApi
  module Test
    module OfficeHelper
      def office_for(case_number:)
        office_code = case_number[0..1].to_i
        Office.where(code: office_code).first
      end

      def office_from_respondent(respondent)
        post_code = respondent.work_address_attributes.try(:post_code) || respondent.address_attributes.try(:post_code)
        code = case post_code
               when /\A(SW1H|WC1)/i then '22'
               else raise "Unknown post code #{post_code} - please add to office_from_respondent method in #{__FILE__}"
               end
        office_for(case_number: code)
      end

    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::OfficeHelper
end
