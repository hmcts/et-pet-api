class CreateExternalSystemConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :external_system_configurations do |t|
      t.references :external_system, null: false
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
