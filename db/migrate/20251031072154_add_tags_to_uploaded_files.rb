class AddTagsToUploadedFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :uploaded_files, :tags, :string
  end
end
