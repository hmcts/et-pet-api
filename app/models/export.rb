# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class Export < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :external_system

  scope :claims, -> { where(resource_type: 'Claim') }
  scope :responses, -> { where(resource_type: 'Response') }
end
