module StoredFileDownload
  extend ActiveSupport::Concern

  def url(local_options: Rails.application.config.action_controller.default_url_options)
    url = URI.parse file.service_url
    if url.host.nil?
      default_options = { scheme: 'http' }
      default_options.merge(local_options).each_pair do |key, value|
        url.send(:"#{key}=", value)
      end
    end
    url.to_s
  end

  def download_blob_to(filename)
    File.open(filename, 'w') do |output_file|
      output_file.binmode
      file.blob.download { |chunk| output_file.write(chunk) }
      output_file.rewind
    end
  end
end
