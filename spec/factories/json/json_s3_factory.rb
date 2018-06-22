require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :json_create_signed_s3_url_command, parent: :json_command do
    command 'CreateSignedS3FormData'
    async false
    data { {} }
  end
end
