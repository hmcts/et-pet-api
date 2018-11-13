# frozen_string_literal: true

# A respondent is the person who the claimant is claiming against
# A claim can have many respondents
class Respondent < ApplicationRecord
  belongs_to :address
  belongs_to :work_address, class_name: 'Address', required: false # rubocop:disable Rails/InverseOf
  accepts_nested_attributes_for :address, reject_if: -> (attrs) { attrs.blank? }
  accepts_nested_attributes_for :work_address, reject_if: -> (attrs) { attrs.blank? }
end
