module OfficeService
  def self.lookup_postcode(postcode)
    postcode = OfficePostCode.with_partial_match(postcode).first
    if postcode
      postcode.office
    else
      Office.default.first
    end
  end
end