module CacheCommandResults
  extend ActiveSupport::Concern

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
      body = yield
      cache_command_results_save(body)
    end
  end

  def cache_command_results_save(body)
    Command.create! id: params[:uuid],
                    request_body: request.body,
                    request_headers: cache_command_results_request_headers,
                    response_body: body,
                    response_headers: response.headers.as_json,
                    response_status: response.status
  end

  def cache_command_results_request_headers
    request.headers.inject({}) do |acc, (key, value)|
      next acc unless ActionDispatch::Http::Headers::CGI_VARIABLES.include?(key)

      acc[key] = value
      acc
    end
  end
end
