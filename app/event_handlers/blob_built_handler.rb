# Currently, this handler is designed to be used with amazon or azure
# as part of the tidy up when we are totally switched over to azure, this will be azure only
# @TODO RST-1676 API (Azure) - Remove all amazon code
class BlobBuiltHandler
  def adapter
    service = Rails.application.config.active_storage.service.to_s
    kls = "::BlobBuiltHandler::#{service.camelize}".safe_constantize
    raise "Unknown service configured in config.active_storage.service" if kls.nil?

    kls.new
  end

  delegate :handle, to: :adapter

  class Amazon
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
      "direct_uploads/#{SecureRandom.uuid}"
    end
  end

  class Azure
    def handle(root)
      blob = ActiveStorage::Blob.new key: key
      build_service_for(blob)
      root[:output_values] ||= {}
      signed_url = signed_url_for(blob)
      assign_parts_to(blob, root, signed_url)
      assign_urls_to(blob, root, signed_url)
    end

    def build_service_for(blob)
      configs = Rails.configuration.active_storage.service_configurations
      config_choice = :azure_direct_upload
      blob.service = ActiveStorage::Service.configure config_choice, configs
    end

    def unsigned_url_for(blob)
      service = blob.service
      service.blobs.generate_uri("#{service.container}/#{blob.key}")
    end

    private

    def assign_parts_to(blob, root, signed_url)
      parts = Rack::Utils.parse_nested_query(URI.parse(signed_url).query)
      root[:output_values][:fields] = {
        key: blob.key,
        permissions: parts['sp'],
        version: parts['sv'],
        expiry: parts['se'],
        resource: parts['sr'],
        signature: parts['sig']
      }
    end

    def assign_urls_to(blob, root, signed_url)
      root[:output_values].merge! url: signed_url,
        unsigned_url: unsigned_url_for(blob)
    end

    def signed_url_for(blob)
      blob.service_url_for_direct_upload
    end

    def key
      "direct_uploads/#{SecureRandom.uuid}"
    end
  end
end
