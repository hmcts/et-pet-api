class UpdateClaimRespondentsWithPrimary < ActiveRecord::Migration[5.2]
  module Admin
    class ClaimRespondent < ActiveRecord::Base
      self.table_name = :claim_respondents
      belongs_to :claim
    end

    class Claim < ActiveRecord::Base
      self.table_name = :claims
    end
  end

  def up
    claims_processed = {}
    Admin::ClaimRespondent.all.each do |c|
      next if claims_processed.key?(c.claim_id)
      claims_processed[c.claim_id] = true
      c.claim.update(primary_respondent_id: c.respondent_id)
      c.destroy
    end
  end

  def down
    # Never reverting this
  end
end
