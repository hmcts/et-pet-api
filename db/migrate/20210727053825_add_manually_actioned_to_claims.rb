class AddManuallyActionedToClaims < ActiveRecord::Migration[6.1]
  def change
    add_column :claims, :manually_actioned, :boolean, index: true, default: false, null: false
  end
end
