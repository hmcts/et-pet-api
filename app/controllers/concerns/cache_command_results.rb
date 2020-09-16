module CacheCommandResults
  extend ActiveSupport::Concern

  included do
    attr_accessor :cached_root_object
  end

  class_methods do
    def cache_command_results(*args)
      around_action :cache_command_results, *args
    end
  end

  private

  def cache_command_results
    cached = Command.where(id: params[:uuid]).first
    if cached
      render plain: cached.response_body, headers: cached.response_headers, status: cached.response_status
    else
      yield
      cache_command_results_save
    end
  end

  def cache_command_results_save
    request.body.rewind
    request_body = request.body.read
    request.body.rewind
    attrs = {
      id: params[:uuid],
      request_body: request_body,
      request_headers: cache_command_results_request_headers,
      response_body: response.body,
      response_headers: response.headers.as_json,
      response_status: response.status
    }
    attrs[:root_object] = cached_root_object if cached_root_object.is_a?(ApplicationRecord) && cached_root_object.persisted?
    Command.create! attrs
  end

  def cache_command_results_request_headers
    request.headers.inject({}) do |acc, (key, value)|
      next acc unless ActionDispatch::Http::Headers::CGI_VARIABLES.include?(key)

      acc[key] = value
      acc
    end
  end
end
