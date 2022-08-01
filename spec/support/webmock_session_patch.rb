require 'webmock'

WebMock::RackResponse.class_eval do
  def build_rack_env_with_session_deleted(request)
    build_rack_env_without_session_deleted(request).tap do |env|
      env.delete('rack.session')
      env.delete('rack.session.options')
    end
  end

  alias_method :build_rack_env_without_session_deleted, :build_rack_env
  alias_method :build_rack_env, :build_rack_env_with_session_deleted
end
