class AssignExistingExportedFilesToAtos < ActiveRecord::Migration[5.2]
  class ExportedFile < ActiveRecord::Base
    self.table_name = :exported_files
  end

  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  def up
    return if ExportedFile.count == 0
    atos = ExternalSystem.where(reference: 'atos').first
    ExportedFile.update_all external_system_id: atos.id
  end

  def down
    # Purposely not doing anything
  end
end
