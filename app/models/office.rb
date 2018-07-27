# frozen_string_literal: true

# An employment tribunal office that handles claims
class Office < ApplicationRecord
  has_many :post_codes, class_name: 'OfficePostCode', dependent: :destroy, inverse_of: :office

  scope :default, -> { where(is_default: true) }
end
