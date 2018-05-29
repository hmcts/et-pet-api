class SignedS3FormDataCreatedHandler
  def handle(root)
    # @TODO - Sort this lot out

    bucket = find_or_create_bucket
    post = bucket.presigned_post(key: root['key'])
    root[:output_values] = {}
    root[:output_values][:fields] = post.fields
    root[:output_values][:url] = post.url
  end

  private

  def client
    @client ||= Aws::S3::Client.new client_config
  end

  def find_or_create_bucket
    Aws::S3::Bucket.new(client: client, name: bucket_name).tap do |bucket|
      bucket.create unless bucket.exists?
    end
  end

  def client_config
    @config ||= begin
      config = {
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', ''),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', ''),
        region: ENV.fetch('AWS_REGION', 'eu-west-1')
      }
      config[:endpoint] = ENV.fetch('AWS_ENDPOINT') if ENV.key?('AWS_ENDPOINT')
      config[:force_path_style] = true if ENV.fetch('AWS_S3_FORCE_PATH_STYLE', 'false') == 'true'
      config
    end
  end

  def bucket_name
    ENV.fetch('S3_DIRECT_UPLOAD_BUCKET')
  end

  def key
    @key ||= "/direct_uploads/#{SecureRandom.uuid}"
  end

  def acl
    'public-read'
  end

  def algorithm
    'AWS4-HMAC-SHA256'
  end

  def success_action_redirect
    "http://sigv4examplebucket.s3.amazonaws.com/successful_upload.html"
  end

  def endpoint
    ENV.fetch('AWS_ENDPOINT')
  end

end
