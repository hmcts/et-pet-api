class CreateOffices < ActiveRecord::Migration[5.1]
  def change
    create_table :offices do |t|
      t.integer :code
      t.string :name
      t.boolean :is_default
      t.string :address
      t.string :telephone
      t.string :email
      t.string :tribunal_type
      t.boolean :is_processing_office

      t.timestamps
    end
  end
end
