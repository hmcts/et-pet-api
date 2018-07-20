class AddUsernameToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :username, :string
    add_column :admin_users, :name, :string
    add_column :admin_users, :department, :string
    add_index :admin_users, :username, unique: true
  end
end
