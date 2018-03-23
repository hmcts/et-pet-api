class CreateAdminPermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_permissions do |t|
      t.string :name

      t.timestamps
    end
  end
end
