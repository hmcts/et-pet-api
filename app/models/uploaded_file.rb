class UploadedFile < ApplicationRecord
  has_one_attached :file

  def file_attributes=(attrs)
    file.attach(a[:file])
  end

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
end