require 'active_storage/service/s3_service'
RSpec.configure do |c|
  c.before(:suite) do
    config = {
      region: ENV.fetch('AWS_REGION', 'us-east-1'),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'accessKey1'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'verySecretKey1'),
      endpoint: ENV.fetch('AWS_ENDPOINT', 'http://localhost:9000/'),
      force_path_style: ENV.fetch('AWS_S3_FORCE_PATH_STYLE', 'true') == 'true'
    }
    s3 = Aws::S3::Client.new(config)
    next unless ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::S3Service)

    Aws::S3::Bucket.new(client: s3, name: ActiveStorage::Blob.service.bucket.name).tap do |bucket|
      bucket.create unless bucket.exists?
      bucket.objects.each(&:delete)
    end
    Aws::S3::Bucket.new(client: s3, name: Rails.configuration.s3_direct_upload_bucket).tap do |bucket|
      bucket.create unless bucket.exists?
      bucket.objects.each(&:delete)
    end

  end
end
