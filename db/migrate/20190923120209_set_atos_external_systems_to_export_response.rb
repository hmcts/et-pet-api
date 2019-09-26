class SetAtosExternalSystemsToExportResponse < ActiveRecord::Migration[6.0]
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  def up
    ExternalSystem.where(reference: ['atos', 'atos_secondary']).each do |system|
      system.export_responses = true
      system.save
    end
  end
end
