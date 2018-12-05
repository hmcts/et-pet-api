class AddExternalServiceIdToExportedFiles < ActiveRecord::Migration[5.2]
  def change
    add_reference :exported_files, :external_system, foreign_key: true
  end
end
