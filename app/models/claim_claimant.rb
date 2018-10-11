# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimClaimant < ApplicationRecord
  belongs_to :claim
  belongs_to :claimant
  default_scope { order(id: :asc) }
end
