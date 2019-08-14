class CorrectManchesterExternalSystem < ActiveRecord::Migration[5.2]
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  class ExternalSystemConfiguration < ActiveRecord::Base
    self.table_name = :external_system_configurations
  end

  def up
    ccd = ExternalSystem.find_by(reference: 'ccd_manchester')

    ExternalSystemConfiguration.where(external_system_id: ccd.id, key: 'user_id').delete_all
    ExternalSystemConfiguration.where(external_system_id: ccd.id, key: 'user_role').delete_all

    ccd.update office_codes: [24]
  end

  def down
    # Purposely do nothing - no point in going back on this
  end
end
