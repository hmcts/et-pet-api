class ChangePrimaryClaimantIdToNotNullInClaims < ActiveRecord::Migration[5.2]
  def change
    change_column_null :claims, :primary_claimant_id, false
  end
end
