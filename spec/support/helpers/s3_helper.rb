RSpec.configure do |c|
  c.before s3_server: true do
    EtApi::Test::S3Helper.new
  end
end
