class AddExportResponsesToExternalSystems < ActiveRecord::Migration[6.0]
  def change
    add_column :external_systems, :export_responses, :boolean, null: false, default: false
  end
end
