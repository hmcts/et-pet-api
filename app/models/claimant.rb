# frozen_string_literal: true

class Claimant < ApplicationRecord
  belongs_to :address
  accepts_nested_attributes_for :address
end
