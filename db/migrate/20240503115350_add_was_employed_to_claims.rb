class AddWasEmployedToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :was_employed, :boolean, default: false
  end
end
