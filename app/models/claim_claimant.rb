# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimClaimant < ApplicationRecord
  belongs_to :claim
  belongs_to :claimant

  accepts_nested_attributes_for :claimant

  def self.primary_claimant
    find_by(primary: true).try(:claimant)
  end

  def self.secondary_claimants
    primary = primary_claimant
    if primary
      where('claimant_id != ?', primary.id)
    else
      self
    end
  end
end
