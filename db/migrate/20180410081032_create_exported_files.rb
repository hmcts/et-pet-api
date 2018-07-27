class CreateExportedFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :exported_files do |t|
      t.string :filename
      t.string :content_type

      t.timestamps
    end
  end
end
