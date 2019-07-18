class AddMultiplesToCcdManchesterExternalSystem < ActiveRecord::Migration[5.2]
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  class ExternalSystemConfiguration < ActiveRecord::Base
    self.table_name = :external_system_configurations
  end

  def up
    ccd = ExternalSystem.find_by(reference: 'ccd_manchester')

    ExternalSystemConfiguration.create external_system_id: ccd.id,
      key: 'multiples_case_type_id', value: 'CCD_Bulk_Action_Manc_v3'
  end

  def down
    # Purposely do nothing - no point in going back on this
  end
end
