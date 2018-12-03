class ConfigureDefaultExternalSystem < ActiveRecord::Migration[5.2]
  class Office < ActiveRecord::Base
    self.table_name=:offices
  end

  class ExternalSystem < ActiveRecord::Base
    self.table_name=:external_systems
  end

  class ExternalSystemConfiguration < ActiveRecord::Base
    self.table_name=:external_system_configurations
  end

  def up
    atos = ExternalSystem.create name: 'ATOS Primary',
      reference: 'atos',
      enabled: true,
      office_codes: Office.pluck(:code).to_a

    atos2 = ExternalSystem.create name: 'ATOS Secondary',
      reference: 'atos_secondary',
      enabled: true,
      office_codes: [99]

    ExternalSystemConfiguration.create external_system_id: atos.id,
      key: 'username', value: ENV.fetch('ATOS_API_USERNAME', 'atos')
    ExternalSystemConfiguration.create external_system_id: atos.id,
      key: 'password', value: ENV.fetch('ATOS_API_PASSWORD', 'password'), can_read: false
    ExternalSystemConfiguration.create external_system_id: atos2.id,
      key: 'username', value: 'atos'
    ExternalSystemConfiguration.create external_system_id: atos2.id,
      key: 'password', value: 'password', can_read: false
  end

  def down
    # Purposely do nothing - no point in going back on this
  end
end
