class CreateExportEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :export_events do |t|
      t.references :export, null: false
      t.string :state, null: true
      t.uuid :uuid
      t.jsonb :data

      t.timestamps
    end
  end
end
