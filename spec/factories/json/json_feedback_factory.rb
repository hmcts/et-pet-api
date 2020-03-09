require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_feedback_response_command, class: ::EtApi::Test::Json::Document do
    trait :full do
      uuid { SecureRandom.uuid }
      command { 'BuildFeedback' }
      data { build(:json_feedback_data) }
    end
  end

  factory :json_feedback_data, class: ::EtApi::Test::Json::Document do
    problems { 'no problems' }
    suggestions { 'Could be better' }
    email_address { "fred#{SecureRandom.hex(10)}@email.com" }
  end
end
