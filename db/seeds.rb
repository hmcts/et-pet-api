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
  office_codes: Office.pluck(:code).to_a - [99]
atos2 = ExternalSystem.create name: 'ATOS Secondary',
  reference: 'atos_secondary',
  enabled: true,
  office_codes: [99]

ExternalSystemConfiguration.create external_system_id: atos.id,
  key: 'username', value: ENV.fetch('ATOS_API_USERNAME', 'atos')
ExternalSystemConfiguration.create external_system_id: atos.id,
  key: 'password', value: ENV.fetch('ATOS_API_PASSWORD', 'password'), can_read: false
ExternalSystemConfiguration.create external_system_id: atos2.id,
  key: 'username', value: 'atos2'
ExternalSystemConfiguration.create external_system_id: atos2.id,
  key: 'password', value: 'password', can_read: false

ccd = ExternalSystem.create name: 'CCD',
  reference: 'ccd_test',
  enabled: true,
  office_codes: Office.pluck(:code).to_a
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'idam_user_token_exchange_url',
  value: 'http://localhost:4501/testing-support/lease'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'idam_service_token_exchange_url',
  value: 'http://localhost:4502/testing-support/lease'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'create_case_url',
  value: 'http://localhost:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/cases'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'initiate_case_url',
  value: 'http://localhost:4452/caseworkers/{uid}/jurisdictions/{jid}/case-types/{ctid}/event-triggers/{etid}/token'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'user_id',
  value: '38'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'user_role',
  value: 'caseworker-publiclaw'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'jurisdiction_id',
  value: 'PUBLICLAW'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'case_type_id',
  value: 'TRIB_MVP_3_TYPE'
ExternalSystemConfiguration.create external_system_id: ccd.id,
  key: 'initiate_case_event_id',
  value: 'initiateCase'




