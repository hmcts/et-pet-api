class Office < ApplicationRecord
  has_many :post_codes, class_name: 'OfficePostCode', dependent: :destroy, inverse_of: :office

  scope :default, -> { where(is_default: true) }
end
