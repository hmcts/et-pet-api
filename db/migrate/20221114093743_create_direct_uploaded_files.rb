class CreateDirectUploadedFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :direct_uploaded_files do |t|
      t.string :filename
      t.string :checksum

      t.timestamps
    end
  end
end
