require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_export_responses_command, class: '::EtApi::Test::Json::Document' do
    transient do
      response_ids { [] }
      external_system_id { nil }
    end
    uuid { SecureRandom.uuid }
    command { 'ExportResponses' }
    data do
      {
        external_system_id: external_system_id,
        response_ids: response_ids
      }
    end
  end
  factory :json_export_claims_command, class: '::EtApi::Test::Json::Document' do
    transient do
      claim_ids { [] }
      external_system_id { nil }
    end
    uuid { SecureRandom.uuid }
    command { 'ExportClaims' }
    data do
      {
        external_system_id: external_system_id,
        claim_ids: claim_ids
      }
    end
  end
end
