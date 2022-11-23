class AddOtherKnownClaimantsToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :other_known_claimants, :boolean
  end
end
