# frozen_string_literal: true

class ClaimClaimant < ApplicationRecord
  belongs_to :claim
  belongs_to :claimant
end
