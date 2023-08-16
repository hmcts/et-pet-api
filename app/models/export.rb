# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class Export < ApplicationRecord
  FINAL_STATES = ['complete', 'failed'].freeze
  belongs_to :resource, polymorphic: true
  belongs_to :external_system
  has_many :events, class_name: 'ExportEvent', dependent: :destroy

  scope :claims, -> { where(resource_type: 'Claim') }
  scope :responses, -> { where(resource_type: 'Response') }
  scope :incomplete, -> { where.not(state: FINAL_STATES) }
  validates :state, inclusion: ['queued', 'created', 'in_progress', 'complete', 'erroring', 'failed']

  def self.mark_as_complete
    update_all(state: 'complete', updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  end
end
