class CreateUserRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_user_roles do |t|
      t.references :user, foreign_key: false
      t.references :role, foreign_key: false
    end
  end
end
