class CreateCommands < ActiveRecord::Migration[5.2]
  def change
    create_table :commands, id: :uuid do |t|
      t.text :request_body, null: false
      t.jsonb :request_headers, null: false
      t.text :response_body, null: false
      t.jsonb :response_headers
      t.integer :response_status
      t.references :root_object, polymorphic: true
      t.timestamps
    end

    add_index :commands, :id, unique: true
  end
end
