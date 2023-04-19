# frozen_string_literal: true

require 'csv'
last_unique_reference = UniqueReference.last
if last_unique_reference.nil? || last_unique_reference.id < 20000000
  ActiveRecord::Base.connection.execute "ALTER SEQUENCE unique_references_id_seq RESTART WITH 20000001;"
end
OfficePostCode.delete_all
Office.delete_all
ExportedFile.delete_all
Export.delete_all
ExternalSystem.delete_all
ExternalSystemConfiguration.delete_all
offices = CSV.read('db/offices.csv', headers: true)
post_codes = CSV.read('db/office_post_codes.csv', headers: true)
offices.each do |office_row|
  office = Office.new code: office_row.fetch('office_code').to_i,
    name: office_row.fetch('office_name'),
    address: office_row.fetch('office_address'),
    telephone: office_row.fetch('office_telephone'),
    email: office_row.fetch('office_email'),
    is_default: office_row.fetch('is_default') == '1'
  post_codes.select {|p| p['office_code'].to_i == office.code}.each do |row|
    office.post_codes.build(postcode: row.fetch('Postcode'))
  end
  office.save
end



atos = ExternalSystem.create name: 'ATOS Primary',
  reference: 'atos',
  enabled: true,
  export_claims: false,
  export_responses: false,
  always_save_export: true,
  office_codes: Office.pluck(:code).to_a - [99]
atos2 = ExternalSystem.create name: 'ATOS Secondary',
  reference: 'atos_secondary',
  enabled: true,
  export_claims: false,
  export_responses: false,
  always_save_export: true,
  office_codes: [99]

ccd_manc = ExternalSystem.create name: 'CCD Manchester',
  reference: 'ccd_manchester',
  enabled: true,
  export_claims: true,
  export_responses: false,
  export_queue: 'external_system_ccd',
  office_codes: [24]

ccd_glasgow = ExternalSystem.create name: 'CCD Glasgow',
  reference: 'ccd_glasgow',
  enabled: true,
  export_claims: true,
  export_responses: false,
  export_queue: 'external_system_ccd',
  office_codes: [41]

ccd_london_central = ExternalSystem.create name: 'CCD London Central',
  reference: 'ccd_london_central',
  enabled: true,
  export_claims: true,
  export_responses: false,
  export_queue: 'external_system_ccd',
  office_codes: [22]

ccd_bristol = ExternalSystem.create name: 'CCD Bristol',
  reference: 'ccd_bristol',
  enabled: true,
  export_claims: true,
  export_responses: true,
  export_queue: 'external_system_ccd',
  office_codes: [14]

ExternalSystemConfiguration.create external_system_id: atos.id,
  key: 'username', value: ENV.fetch('ATOS_API_USERNAME', 'atos')
ExternalSystemConfiguration.create external_system_id: atos.id,
  key: 'password', value: ENV.fetch('ATOS_API_PASSWORD', 'password'), can_read: false
ExternalSystemConfiguration.create external_system_id: atos2.id,
  key: 'username', value: 'atos2'
ExternalSystemConfiguration.create external_system_id: atos2.id,
  key: 'password', value: 'password', can_read: false
ExternalSystemConfiguration.create external_system_id: ccd_manc.id,
  key: 'case_type_id', value: 'Manchester_Dev'
ExternalSystemConfiguration.create external_system_id: ccd_manc.id,
  key: 'multiples_case_type_id', value: 'Manchester_Multiples_Dev'
ExternalSystemConfiguration.create external_system_id: ccd_glasgow.id,
  key: 'case_type_id', value: 'Glasgow_Dev'
ExternalSystemConfiguration.create external_system_id: ccd_glasgow.id,
  key: 'multiples_case_type_id', value: 'Glasgow_Multiples_Dev'

ExternalSystem.create! name: 'CCD England And Wales (Reform)',
                      reference: 'ccd_england_and_wales_reform',
                      enabled: true,
                      export_claims: true,
                      export_responses: true,
                      export_queue: 'external_system_ccd',
                      office_codes: [60],
                      configurations_attributes: [
                              { key: 'case_type_id', value: 'ET_EnglandWales' },
                              { key: 'multiples_case_type_id',value: 'ET_EnglandWales_Multiples' },
                              { key: 'send_request_id', value: 'true' }
                            ]
ExternalSystem.create! name: 'CCD Test2',
                      reference: 'ccd_test2',
                      enabled: true,
                      export_claims: true,
                      export_responses: false,
                      export_queue: 'external_system_ccd',
                      office_codes: [61],
                      configurations_attributes: [
                              { key: 'case_type_id', value: 'Test2' },
                              { key: 'multiples_case_type_id',value: 'Test2_Multiples' },
                              { key: 'extra_headers', value: { force_failures: { token_stage: [401, 401, 401] } }.to_json},
                              { key: 'send_request_id', value: 'true' }
                            ]
ExternalSystem.create! name: 'CCD Test3',
                      reference: 'ccd_test3',
                      enabled: true,
                      export_claims: true,
                      export_responses: false,
                      export_queue: 'external_system_ccd',
                      office_codes: [62],
                      configurations_attributes: [
                              { key: 'case_type_id', value: 'Test3' },
                              { key: 'multiples_case_type_id',value: 'Test3_Multiples' },
                              { key: 'extra_headers', value: { force_failures: { token_stage: [401, 401, 401, 401, 401, 504, 401] } }.to_json},
                              { key: 'send_request_id', value: 'true' }
                            ]
ExternalSystem.create! name: 'CCD Test4',
                      reference: 'ccd_test4',
                      enabled: true,
                      export_claims: true,
                      export_responses: false,
                      export_queue: 'external_system_ccd',
                      office_codes: [63],
                      configurations_attributes: [
                              { key: 'case_type_id', value: 'Test4' },
                              { key: 'multiples_case_type_id',value: 'Test4_Multiples' },
                              { key: 'extra_headers', value: { force_failures: { token_stage: [401] } }.to_json},
                              { key: 'send_request_id', value: 'true' }
                            ]
ExternalSystem.create! name: 'CCD Test5',
                      reference: 'ccd_test5',
                      enabled: true,
                      export_claims: true,
                      export_responses: false,
                      export_queue: 'external_system_ccd',
                      office_codes: [64],
                      configurations_attributes: [
                              { key: 'case_type_id', value: 'Test5' },
                              { key: 'multiples_case_type_id',value: 'Test5_Multiples' },
                              { key: 'extra_headers', value: { force_failures: { token_stage: [401, 401, 401] } }.to_json},
                              { key: 'send_request_id', value: 'true' }
                            ]
ExternalSystem.create! name: 'CCD Scotland (Reform)',
                      reference: 'ccd_scotland_reform',
                      enabled: true,
                      export_claims: true,
                      export_responses: true,
                      export_queue: 'external_system_ccd',
                      office_codes: [80],
                      configurations_attributes: [
                              { key: 'case_type_id', value: 'ET_Scotland' },
                              { key: 'multiples_case_type_id',value: 'ET_Scotland_Multiples' },
                              { key: 'send_request_id', value: 'true' }
                            ]
