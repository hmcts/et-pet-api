class UpdateClaimClaimantsWithPrimary < ActiveRecord::Migration[5.2]
  module Admin
    class ClaimClaimant < ActiveRecord::Base
      self.table_name = :claim_claimants
    end
  end

  def up
    claims_processed = {}
    ClaimClaimant.all.each do |c|
      next if claims_processed.key?(c.claim_id)
      claims_processed[c.claim_id] = true
      c.update primary: true
    end
  end

  def down
    # Never reverting this
  end
end
