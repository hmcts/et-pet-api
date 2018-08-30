class UpdateClaimClaimantsWithPrimary < ActiveRecord::Migration[5.2]
  module Admin
    class ClaimClaimant < ActiveRecord::Base
      self.table_name = :claim_claimants
      belongs_to :claim
    end

    class Claim < ActiveRecord::Base
      self.table_name = :claims
    end
  end

  def up
    claims_processed = {}
    Admin::ClaimClaimant.all.each do |c|
      next if claims_processed.key?(c.claim_id)
      claims_processed[c.claim_id] = true
      c.claim.update(primary_claimant_id: c.claimant_id)
      c.destroy
    end
  end

  def down
    # Never reverting this
  end
end
