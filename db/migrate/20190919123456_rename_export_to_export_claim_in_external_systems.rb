class RenameExportToExportClaimInExternalSystems < ActiveRecord::Migration[6.0]
  def change
    change_table :external_systems do |t|
      t.rename :export, :export_claims
    end
  end
end
