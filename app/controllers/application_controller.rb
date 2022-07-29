class ApplicationController < ActionController::API
  before_action do
    ActiveStorage::Current.url_options = { host: request.base_url }
  end
end
