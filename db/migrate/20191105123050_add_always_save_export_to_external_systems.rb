class AddAlwaysSaveExportToExternalSystems < ActiveRecord::Migration[6.0]
  def change
    add_column :external_systems, :always_save_export, :boolean, default: false
  end
end
