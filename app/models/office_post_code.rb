# An office can have many office post codes, which are the post codes (or partial)
# that the office serves.
# This allows a lookup (using with_partial_match) when a claim is submitted, so the system
# can decide which office it is to be sent to.
class OfficePostCode < ApplicationRecord
  belongs_to :office

  scope :active, -> { where.not(postcode: nil) }
  scope :with_partial_match, lambda { |postcode|
    active.where("? ILIKE concat(postcode, '%')", postcode).order(Arel.sql('length(postcode) DESC'))
  }
end
