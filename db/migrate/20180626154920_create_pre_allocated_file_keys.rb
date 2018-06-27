class CreatePreAllocatedFileKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :pre_allocated_file_keys do |t|
      t.string :key
      t.references :allocated_to, polymorphic: true, index: { name: 'index_pre_allocated_file_keys_to_allocated_id_and_type'}
      t.string :filename

      t.timestamps
    end
  end
end
