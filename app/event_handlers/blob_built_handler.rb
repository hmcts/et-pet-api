class BlobBuiltHandler
  def handle(root)
    blob = ActiveStorage::Blob.new key: key
    build_service_for(blob)
    root[:output_values] ||= {}
    signed_url = signed_url_for(blob)
    assign_parts_to(blob, root, signed_url)
    assign_urls_to(blob, root, signed_url)
  end

  def build_service_for(blob)
    config = Rails.configuration.active_storage
    blob.service_name = :"#{config.service}_direct_upload"
  end

  def unsigned_url_for(blob)
    service = blob.service
    service.client.generate_uri("#{service.container}/#{blob.key}")
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
