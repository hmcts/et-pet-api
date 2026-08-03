shared_context 'with fake job processor' do
  def run_background_jobs
    loop do
      break if perform_enqueued_jobs(only: ->(job, *_args) { job['queue_name'].in?(['events', 'default']) }).zero?
    end
  end
end
