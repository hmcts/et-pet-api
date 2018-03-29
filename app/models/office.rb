class Office < ApplicationRecord
  has_many :post_codes, class_name: 'OfficePostCode'

  scope :default, -> { where(is_default: true) }
end
