# frozen_string_literal: true

class Respondent < ApplicationRecord
  belongs_to :address
  belongs_to :work_address, class_name: 'Address', required: false # rubocop:disable Rails/InverseOf
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :work_address
end
