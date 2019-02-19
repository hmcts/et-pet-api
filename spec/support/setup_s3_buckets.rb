require 'active_storage/service/s3_service'
RSpec.configure do |c|
  c.before(:suite) do
    ActiveStorage::Blob.service # Will ensure active storage is configured
    config = Rails.configuration.active_storage.service_configurations['amazon'].symbolize_keys
    s3 = Aws::S3::Client.new(config.except(:service, :bucket))

    Aws::S3::Bucket.new(client: s3, name: config[:bucket]).tap do |bucket|
      bucket.create unless bucket.exists?
      bucket.objects.each(&:delete)
    end
    Aws::S3::Bucket.new(client: s3, name: Rails.configuration.s3_direct_upload_bucket).tap do |bucket|
      bucket.create unless bucket.exists?
      bucket.objects.each(&:delete)
    end

  end
end
