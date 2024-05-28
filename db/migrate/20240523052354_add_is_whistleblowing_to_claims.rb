class AddIsWhistleblowingToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :is_whistleblowing, :boolean
  end
end
