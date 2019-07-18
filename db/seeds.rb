# frozen_string_literal: true

require 'csv'
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
  export: false,
  office_codes: Office.pluck(:code).to_a - [99]
atos2 = ExternalSystem.create name: 'ATOS Secondary',
  reference: 'atos_secondary',
  enabled: true,
  export: false,
  office_codes: [99]
ccd = ExternalSystem.create name: 'CCD Manchester',
  reference: 'ccd_manchester',
  enabled: true,
  export: true,
  export_queue: 'external_system_ccd',
  office_codes: Office.pluck(:code).to_a - [99]

ExternalSystemConfiguration.create external_system_id: atos.id,
  key: 'username', value: ENV.fetch('ATOS_API_USERNAME', 'atos')
ExternalSystemConfiguration.create external_system_id: atos.id,
  key: 'password', value: ENV.fetch('ATOS_API_PASSWORD', 'password'), can_read: false
ExternalSystemConfiguration.create external_system_id: atos2.id,
  key: 'username', value: 'atos2'
ExternalSystemConfiguration.create external_system_id: atos2.id,
  key: 'password', value: 'password', can_read: false
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'user_id', value: '22'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'user_role', value: 'caseworker,caseworker-test,caseworker-employment-tribunal-manchester,caseworker-employment,caseworker-employment-tribunal-manchester-caseofficer,caseworker-publiclaw-localAuthority'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'case_type_id', value: 'EmpTrib_MVP_1.0_Manc'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'multiples_case_type_id', value: 'CCD_Bulk_Action_Manc_v3'


