class ConvertClaimExportToPolymorphic < ActiveRecord::Migration[5.2]
  class ClaimExport < ::ActiveRecord::Base
    self.table_name = :claim_exports
  end

  def up

    change_table :claim_exports do |t|
      t.references :resource, polymorphic: true
      t.remove :resource_id
      t.rename :claim_id, :resource_id
    end
    ClaimExport.update_all(resource_type: 'Claim')
  end

  def down
    change_table :claim_exports do |t|
      t.rename :resource_id, :claim_id
      t.remove :resource_type
    end

  end
end
