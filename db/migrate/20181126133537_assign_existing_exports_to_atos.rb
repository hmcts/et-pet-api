class AssignExistingExportsToAtos < ActiveRecord::Migration[5.2]
  class Export < ActiveRecord::Base
    self.table_name = :exports
  end

  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  def up
    return if Export.count == 0
    atos = ExternalSystem.where(reference: 'atos').first
    Export.update_all external_system_id: atos.id
  end

  def down
    # Purposely not doing anything
  end
end
