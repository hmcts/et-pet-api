class RenameClaimExportsToExports < ActiveRecord::Migration[5.2]
  def change
    rename_table :claim_exports, :exports
  end
end
