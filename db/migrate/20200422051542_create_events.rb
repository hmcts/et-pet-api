class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.references :attached_to, polymorphic: true, null: false
      t.string :name, null: false
      t.jsonb :data, default: {}

      t.timestamps
    end
  end
end
