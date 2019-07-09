class AddExportQueueToExternalSystems < ActiveRecord::Migration[5.2]
  def change
    add_column :external_systems, :export_queue, :string
    add_column :external_systems, :export, :boolean, default: false
    ActiveRecord::Base.clear_cache!
  end
end
