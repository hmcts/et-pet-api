require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_export_responses_command, class: ::EtApi::Test::Json::Document do
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
end
