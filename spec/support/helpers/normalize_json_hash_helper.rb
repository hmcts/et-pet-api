module EtApi
  module Test
    module NormalizeJsonHashHelper
      def normalize_json_claim(json_hash)
        h = json_hash.symbolize_keys
        h[:date_of_receipt] = Date.parse(h.delete(:date_of_receipt)) unless h[:date_of_receipt].nil?
        h
      end

      def normalize_json_claimant(json_hash)
        h = json_hash.symbolize_keys
        h[:address] = normalize_json_address(h.delete(:address_attributes))
        h[:date_of_birth] = Date.parse(h[:date_of_birth])
        h
      end

      def normalize_json_claimants(claimants_array)
        claimants_array.map do |claimant_hash|
          normalize_json_claimant(claimant_hash)
        end
      end

      def normalize_json_respondents(respondents_array)
        respondents_array.map do |respondent_hash|
          normalize_json_respondent(respondent_hash)
        end
      end

      def normalize_json_respondent(respondent)
        h = respondent.symbolize_keys
        h[:address] = normalize_json_address(h.delete(:address_attributes))
        h[:work_address] = normalize_json_address(h.delete(:work_address_attributes))
        h
      end

      def normalize_json_representative(representative)
        h = representative.symbolize_keys
        h[:address] = normalize_json_address(h.delete(:address_attributes))
        h
      end

      def normalize_json_address(address_hash)
        address_hash.to_h.symbolize_keys
      end
    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::NormalizeJsonHashHelper
end
