class AddLockableToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :admin_users do |t|

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at
    end

    add_index :admin_users, :unlock_token,         unique: true
  end
end
