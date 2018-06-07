module HealthStatus
  class Deployment
    def as_json(_options = {})
      {
        version_number: ENV.fetch('APP_VERSION', 'unknown'),
        build_date: ENV.fetch('APP_BUILD_DATE', 'unknown'),
        commit_id: ENV.fetch('APP_GIT_COMMIT', 'unknown'),
        build_tag: ENV.fetch('APP_BUILD_TAG', 'unknown')
      }
    end
  end
end
