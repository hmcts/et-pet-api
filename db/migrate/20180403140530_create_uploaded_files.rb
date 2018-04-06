class CreateUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :uploaded_files do |t|
      t.string :filename
      t.string :checksum

      t.timestamps
    end
  end
end
