# frozen_string_literal: true

json.status result.valid? ? 'created' : 'invalid'
json.meta result.meta
json.uuid result.uuid
json.data do
  json.reference data[:reference]
  json.office do
    json.code data[:office].code.to_s
    json.name data[:office].name
    json.address data[:office].address
    json.telephone data[:office].telephone
  end
end
