# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class Export < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :external_system
  has_many :events, class_name: 'ExportEvent'

  scope :claims, -> { where(resource_type: 'Claim') }
  scope :responses, -> { where(resource_type: 'Response') }

  validates :state, inclusion: ['queued', 'created', 'in_progress', 'complete']
end
