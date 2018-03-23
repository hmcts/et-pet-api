class AddAdminRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_roles do |t|
      t.string :name, null: false
      t.boolean :is_admin, default: false
    end
  end
end
