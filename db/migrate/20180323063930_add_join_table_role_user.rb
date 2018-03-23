class AddJoinTableRoleUser < ActiveRecord::Migration[5.1]
  def change
    create_join_table :roles, :users, table_name: :admin_roles_users do |t|
      t.index [:role_id, :user_id]
      t.index [:user_id, :role_id]
    end
  end
end
