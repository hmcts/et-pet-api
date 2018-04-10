class OfficePostCode < ApplicationRecord
  belongs_to :office

  scope :active, -> { where('postcode is not null') }
  scope :with_partial_match, -> (postcode) { active.where("? LIKE concat(postcode, '%')", postcode).order(Arel.sql('length(postcode) DESC')) }
end
