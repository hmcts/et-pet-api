class AddProgressMessagesToExportEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :export_events, :percent_complete, :integer, null: false, default: 0
    add_column :export_events, :message, :string
  end
end
