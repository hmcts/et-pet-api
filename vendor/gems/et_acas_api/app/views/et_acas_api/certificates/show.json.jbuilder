# frozen_string_literal: true

json.status result.status
json.data do
  json.claimant_name certificate.claimant_name
  json.respondent_name certificate.respondent_name
  json.certificate_number certificate.certificate_number
  json.date_of_issue certificate.date_of_issue
  json.date_of_receipt certificate.date_of_receipt
  json.message certificate.message
  json.method_of_issue certificate.method_of_issue
  json.certificate_base64 certificate.certificate_base64
end
