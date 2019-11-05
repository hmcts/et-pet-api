class ConfigureAlwaysSaveExports < ActiveRecord::Migration[6.0]
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  def up
    ExternalSystem.where(reference: ['atos', 'atos_secondary']).each do |system|
      system.export_responses = false
      system.always_save_export = true
      system.save
    end
  end
end
