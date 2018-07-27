# frozen_string_literal: true

# A representative for an employment tribunal claim
class Representative < ApplicationRecord
  belongs_to :address
  accepts_nested_attributes_for :address
end
