class AddImportFileColumnsToUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :uploaded_files, :import_file_url, :string
    add_column :uploaded_files, :import_from_key, :string
  end
end
