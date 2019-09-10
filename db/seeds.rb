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
  post_codes.select { |p| p['office_code'].to_i == office.code }.each do |row|
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

ExternalSystemConfiguration.create external_system_id: atos.id,
                                   key: 'username', value: ENV.fetch('ATOS_API_USERNAME', 'atos')
ExternalSystemConfiguration.create external_system_id: atos.id,
                                   key: 'password', value: ENV.fetch('ATOS_API_PASSWORD', 'password'), can_read: false
ExternalSystemConfiguration.create external_system_id: atos2.id,
                                   key: 'username', value: 'atos2'
ExternalSystemConfiguration.create external_system_id: atos2.id,
                                   key: 'password', value: 'password', can_read: false
offices = {
  24 => {id: 'Manchester', export: true},
  41 => {id: 'Scotland', export: true},
  14 => {id: 'Bristol', export: false},
  18 => {id: 'Leeds', export: false},
  22 => {id: 'LondonCentral', export: false},
  32 => {id: 'LondonEast', export: false},
  23 => {id: 'LondonSouth', export: false},
  26 => {id: 'MidlandsEast', export: false},
  13 => {id: 'MidlandsWest', export: false},
  25 => {id: 'Newcastle', export: false},
  16 => {id: 'Wales', export: false},
  33 => {id: 'Watford', export: false}
}
offices.each_pair do |office_code, options|
  ccd = ExternalSystem.create name: "CCD #{options[:id]}",
                              reference: "ccd_#{options[:id].underscore}",
                              enabled: true,
                              export: options[:export],
                              export_queue: 'external_system_ccd',
                              office_codes: [office_code]
  ExternalSystemConfiguration.create external_system_id: ccd.id,
                                     key: 'case_type_id', value: options[:id]
  ExternalSystemConfiguration.create external_system_id: ccd.id,
                                     key: 'multiples_case_type_id', value: "#{options[:id]}_Multiples"

end

