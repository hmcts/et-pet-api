shared_context 'with fake job processor' do
  def run_background_jobs(only: nil, except: nil, queue: nil)
    if only.nil? && except.nil? && queue.nil?
      only = ->(job, *_args) { job['queue_name'].in?(['events', 'default', 'external_system_ccd', 'external_system_ccd_callbacks', 'external_system_ccd_multiples']) }
    end

    loop do
      break if perform_enqueued_jobs(only: only, except: except, queue: queue).zero?
    end
  end
end
