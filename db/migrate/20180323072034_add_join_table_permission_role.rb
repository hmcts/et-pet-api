class AddJoinTablePermissionRole < ActiveRecord::Migration[5.1]
  def change
    create_join_table :permissions, :roles, table_name: :admin_permissions_roles do |t|
      # t.index [:admin_permission_id, :admin_role_id]
      # t.index [:admin_role_id, :admin_permission_id]
    end
  end
end
