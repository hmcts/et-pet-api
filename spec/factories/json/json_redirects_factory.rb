require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_redirect_claim_command, class: ::EtApi::Test::Json::Document do
    transient do
      claim_id { nil }
      office_id { nil }
    end
    uuid { SecureRandom.uuid }
    command { 'RedirectClaim' }
    data do
      {
        office_id: office_id,
        claim_id: claim_id
      }
    end
  end
end
