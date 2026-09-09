# frozen_string_literal: true

require 'csv'
last_unique_reference = UniqueReference.last
if last_unique_reference.nil? || last_unique_reference.id < 20000000
  ActiveRecord::Base.connection.execute "ALTER SEQUENCE unique_references_id_seq RESTART WITH 20000001;"
end
offices = CSV.read('db/offices.csv', headers: true)
post_codes = CSV.read('db/office_post_codes.csv', headers: true)
offices.each do |office_row|
  office = Office.find_or_initialize_by code: office_row.fetch('office_code').to_i
  office.assign_attributes name: office_row.fetch('office_name'),
    address: office_row.fetch('office_address'),
    telephone: office_row.fetch('office_telephone'),
    email: office_row.fetch('office_email'),
    is_default: office_row.fetch('is_default') == '1'
  post_codes.select {|p| p['office_code'].to_i == office.code}.each do |row|
    next if office.post_codes.exists?(postcode: row.fetch('Postcode'))

    office.post_codes.build(postcode: row.fetch('Postcode'))
  end
  office.save
end



ccd_manc = ExternalSystem.find_or_initialize_by name: 'CCD Manchester', reference: 'ccd_manchester'
ccd_manc.update! enabled: true,
  export_claims: true,
  export_responses: true,
  export_queue: 'external_system_ccd',
  office_codes: [24]

ccd_glasgow = ExternalSystem.find_or_initialize_by name: 'CCD Glasgow', reference: 'ccd_glasgow'
ccd_glasgow.update! enabled: true,
  export_claims: true,
  export_responses: true,
  export_queue: 'external_system_ccd',
  office_codes: [41]

ccd_london_central = ExternalSystem.find_or_initialize_by reference: 'ccd_london_central'
ccd_london_central.update! enabled: true,
                           name: 'CCD London Central',
                           export_claims: true,
                           export_responses: true,
                           export_queue: 'external_system_ccd',
                           office_codes: [22]

ccd_bristol = ExternalSystem.find_or_initialize_by reference: 'ccd_bristol'
ccd_bristol.update! enabled: true,
                    name: 'CCD Bristol',
                    export_claims: true,
                    export_responses: true,
                    export_queue: 'external_system_ccd',
                    office_codes: [14]

ExternalSystemConfiguration.find_or_create_by external_system_id: ccd_manc.id,
  key: 'case_type_id', value: 'Manchester_Dev'
ExternalSystemConfiguration.find_or_create_by external_system_id: ccd_manc.id,
  key: 'multiples_case_type_id', value: 'Manchester_Multiples_Dev'
ExternalSystemConfiguration.find_or_create_by external_system_id: ccd_glasgow.id,
  key: 'case_type_id', value: 'Glasgow_Dev'
ExternalSystemConfiguration.find_or_create_by external_system_id: ccd_glasgow.id,
  key: 'multiples_case_type_id', value: 'Glasgow_Multiples_Dev'

ExternalSystem.find_or_create_by! reference: 'ccd_england_and_wales_reform' do |external_system|
  external_system.assign_attributes enabled: true,
                                    name: 'CCD England And Wales (Reform)',
                                    export_claims: true,
                                    export_responses: true,
                                    response_remote_office: true,
                                    export_queue: 'external_system_ccd',
                                    office_codes: [60],
                                    configurations_attributes: [
                                      { key: 'case_type_id', value: 'ET_EnglandWales' },
                                      { key: 'multiples_case_type_id',value: 'ET_EnglandWales_Multiples' },
                                      { key: 'send_request_id', value: 'true' }
                                    ]
  end
ExternalSystem.find_or_create_by! reference: 'ccd_test2' do |external_system|
  external_system.assign_attributes enabled: true,
                                    name: 'CCD Test2',
                                    export_claims: true,
                                    export_responses: true,
                                    export_queue: 'external_system_ccd',
                                    office_codes: [61],
                                    configurations_attributes: [
                                            { key: 'case_type_id', value: 'Test2' },
                                            { key: 'multiples_case_type_id',value: 'Test2_Multiples' },
                                            { key: 'extra_headers', value: { force_failures: { token_stage: [401, 401, 401] } }.to_json},
                                            { key: 'send_request_id', value: 'true' }
                                          ]
  end
ExternalSystem.find_or_create_by! reference: 'ccd_test3' do |external_system|
  external_system.assign_attributes enabled: true,
                                    name: 'CCD Test3',
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
  end
ExternalSystem.find_or_create_by! reference: 'ccd_test4' do |external_system|
  external_system.assign_attributes enabled: true,
                                    name: 'CCD Test4',
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
  end
ExternalSystem.find_or_create_by! reference: 'ccd_test5' do |external_system|
  external_system.assign_attributes enabled: true,
                                    name: 'CCD Test5',
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
  end
ExternalSystem.find_or_create_by! reference: 'ccd_scotland_reform' do |external_system|
  external_system.assign_attributes enabled: true,
                                    name: 'CCD Scotland (Reform)',
                                    export_claims: true,
                                    export_responses: true,
                                    export_queue: 'external_system_ccd',
                                    office_codes: [80],
                                    configurations_attributes: [
                                      { key: 'case_type_id', value: 'ET_Scotland' },
                                      { key: 'multiples_case_type_id',value: 'ET_Scotland_Multiples' },
                                      { key: 'send_request_id', value: 'true' }
                                    ]
  end
