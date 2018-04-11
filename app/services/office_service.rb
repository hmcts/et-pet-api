# frozen_string_literal: true

# Services related to offices
module OfficeService
  # Finds the office by postcode or the default office if it can't find one
  #
  # @param [String] postcode The post code to search for
  # @return [Office] The office found or the default if not found
  def self.lookup_postcode(postcode)
    postcode = OfficePostCode.with_partial_match(postcode).first
    if postcode
      postcode.office
    else
      Office.default.first
    end
  end
end