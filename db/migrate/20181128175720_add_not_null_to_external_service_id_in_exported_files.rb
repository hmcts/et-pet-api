class AddNotNullToExternalServiceIdInExportedFiles < ActiveRecord::Migration[5.2]
  def change
    change_column_null :exported_files, :external_system_id, false
  end
end
