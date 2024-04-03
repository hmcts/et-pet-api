# frozen_string_literal: true

class ClaimDestroyJob < ApplicationJob
  queue_as :default

  def perform(claim_id)
    Claim.find(claim_id).destroy!
  end
end
