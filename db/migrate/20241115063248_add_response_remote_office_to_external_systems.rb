class AddResponseRemoteOfficeToExternalSystems < ActiveRecord::Migration[7.1]
  def change
    add_column :external_systems, :response_remote_office, :boolean, null: false, default: false
  end
end
