# This module is included in any models that need to be able to download a file stored in
# active storage
#
module StoredFileDownload
  extend ActiveSupport::Concern

  # Calculates the URL whether local or remote
  #
  # @param [Hash] local_options Used to add the host etc.. to the local path - defaults to
  #   Rails.application.config.action_controller.default_url_options
  #
  # @return [String] The url to download from
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

  # Downloads the stored file to the local file system
  #
  # @param [String] filename The filename to download to
  def download_blob_to(filename)
    File.open(filename, 'w') do |output_file|
      output_file.binmode
      file.blob.download { |chunk| output_file.write(chunk) }
      output_file.rewind
    end
  end
end
