class AddProgressMessagesToExports < ActiveRecord::Migration[6.0]
  def change
    add_column :exports, :percent_complete, :integer, null: false, default: 0
    add_column :exports, :message, :string
  end
end
