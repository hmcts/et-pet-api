class AddFileScopeToUploadedFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :uploaded_files, :file_scope, :string, default: 'system'
    add_index :uploaded_files, :file_scope, unique: false
  end
end
