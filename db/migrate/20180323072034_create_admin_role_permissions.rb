class CreateAdminRolePermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_role_permissions do |t|
      t.references :role, foreign_key: false
      t.references :permission, foreign_key: false
    end
  end
end
