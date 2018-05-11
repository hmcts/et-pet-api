class CreateResponseExports < ActiveRecord::Migration[5.2]
  def change
    create_table :response_exports do |t|
      t.references :response, foreign_key: true
      t.boolean :in_progress
      t.string :messages, array: true, default: []

      t.timestamps
    end
  end
end
