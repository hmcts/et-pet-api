class CreateResponseUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :response_uploaded_files do |t|
      t.references :response, foreign_key: true
      t.references :uploaded_file, foreign_key: true

      t.timestamps
    end
  end
end
