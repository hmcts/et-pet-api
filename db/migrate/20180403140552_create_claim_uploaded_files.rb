class CreateClaimUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_uploaded_files do |t|
      t.references :claim, foreign_key: true
      t.references :uploaded_file, foreign_key: true

      t.timestamps
    end
  end
end
