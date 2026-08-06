GoodJob.configure_active_record do
  connects_to database: { writing: :queue }
end

# Support deployments whose chart still uses the former queue worker health path.
Rails.application.config.good_job.probe_app = lambda do |env|
  env = env.merge("PATH_INFO" => "/status/connected") if env["PATH_INFO"] == "/health"
  GoodJob::ProbeServer.default_app.call(env)
end
