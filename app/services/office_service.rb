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


  # Finds the office given a specific case number
  #
  # @param [String] case_number The case number in the format oonnnnnn/yyyy where 'oo' is the office code
  #
  # @return [Office, Nil] If found, the office instance else nil
  def self.lookup_by_case_number(case_number)
    Office.where(code: case_number[0..1].to_i).first
  end
end
