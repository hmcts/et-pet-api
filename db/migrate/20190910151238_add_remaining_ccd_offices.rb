class AddRemainingCcdOffices < ActiveRecord::Migration[6.0]
  class ExternalSystem < ActiveRecord::Base
    self.table_name = :external_systems
  end

  class ExternalSystemConfiguration < ActiveRecord::Base
    self.table_name = :external_system_configurations
  end

  def up
    offices = {
      14 => 'Bristol',
      18 => 'Leeds',
      22 => 'LondonCentral',
      32 => 'LondonEast',
      23 => 'LondonSouth',
      26 => 'MidlandsEast',
      13 => 'MidlandsWest',
      25 => 'Newcastle',
      16 => 'Wales',
      33 => 'Watford'
    }
    offices.each_pair do |office_code, single_case_id|
      ccd = ExternalSystem.find_by(reference: "ccd_#{single_case_id.underscore}")
      if ccd.present?
        ccd.update office_codes: [office_code]
      else
        ccd = ExternalSystem.create name: "CCD #{single_case_id}",
                              reference: "ccd_#{single_case_id.underscore}",
                              enabled: true,
                              export: false,
                              export_queue: 'external_system_ccd',
                              office_codes: [office_code]
      end
      ExternalSystemConfiguration.create external_system_id: ccd.id,
                                         key: 'case_type_id', value: single_case_id
      ExternalSystemConfiguration.create external_system_id: ccd.id,
                                         key: 'multiples_case_type_id', value: "#{single_case_id}_Multiples"

    end
  end

  def down
    # Not reverting this
  end
end
