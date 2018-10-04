# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimRepresentative < ApplicationRecord
  belongs_to :claim
  belongs_to :representative
  default_scope { order(created_at: :asc) }
end
