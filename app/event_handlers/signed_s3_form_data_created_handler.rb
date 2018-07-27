class SignedS3FormDataCreatedHandler
  def handle(root)
    post = find_or_create_bucket.presigned_post(key: key, success_action_status: '201')
    root[:output_values] = {}
    root[:output_values][:fields] = post.fields
    root[:output_values][:url] = post.url
  end

  private

  def client
    @client ||= ActiveStorage::Blob.service.client.client
  end

  def find_or_create_bucket
    Aws::S3::Bucket.new(client: client, name: bucket_name).tap do |bucket|
      bucket.create unless bucket.exists?
    end
  end

  def bucket_name
    @bucket_name ||= Rails.configuration.s3_direct_upload_bucket
  end

  def key
    @key ||= "direct_uploads/#{SecureRandom.uuid}"
  end
end
