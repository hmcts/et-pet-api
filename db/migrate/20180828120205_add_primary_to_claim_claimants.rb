class AddPrimaryToClaimClaimants < ActiveRecord::Migration[5.2]
  def change
    add_column :claim_claimants, :primary, :boolean, default: false
  end
end
