class CreateExternalSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :external_systems do |t|
      t.string :name, null: false
      t.string :reference, null: false
      t.integer :office_codes, array: true, default: []
      t.boolean :enabled, default: true

      t.timestamps

      t.index :reference, unique: true
    end
  end
end
