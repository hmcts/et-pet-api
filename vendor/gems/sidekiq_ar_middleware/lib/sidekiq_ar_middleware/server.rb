require 'sidekiq_ar_middleware/active_record_un_wrapper'
module SidekiqArMiddleware
  class Server
    def call(worker, job, queue)
      process_args job['args']
      yield
    end

    private

    def process_args(args)
      args.each_with_index do |arg, idx|
        args[idx] = process_arg(arg)
      end
    end

    def process_arg(arg)
      case arg
      when Hash then
        process_hash_arg(arg)
      else
        arg
      end
    end

    def process_hash_arg(arg)
      if arg['type'] == 'sidekiq_ar_middleware_ar_wrapper'
        process_ar_wrapper_arg(arg)
      else
        arg
      end
    end

    def process_ar_wrapper_arg(arg)
      ActiveRecordUnWrapper.new(arg).record
    end
  end
end
