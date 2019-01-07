require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_command, class: ::EtApi::Test::Json::Node do
    uuid { SecureRandom.uuid }
    command { 'DummyCommand' }
    data { EtApi::Test::Json::Node.new }
  end
end
