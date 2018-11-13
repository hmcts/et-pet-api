# frozen_string_literal: true

# A claimant is someone claiming for an employee tribunal - a claim can have multiple claimants
class Claimant < ApplicationRecord
  belongs_to :address
  accepts_nested_attributes_for :address, reject_if: -> (attrs) { attrs.blank? }
end
