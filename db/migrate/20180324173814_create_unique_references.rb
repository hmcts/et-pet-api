class CreateUniqueReferences < ActiveRecord::Migration[5.1]
  def change
    create_table :unique_references do |t|
      t.integer :number

      t.timestamps
    end
  end
end
