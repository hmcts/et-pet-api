require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_build_blob_command, parent: :json_command do
    command { 'BuildBlob' }
    async { false }
    data { nil }
  end
end
