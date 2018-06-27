require 'sidekiq_ar_middleware/active_record_wrapper'
module SidekiqArMiddleware
  class Client
    def call(worker_class, job, queue, redis_pool)
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
      when ActiveRecord::Base then
        process_active_record_arg(arg)
      else
        arg
      end
    end

    def process_active_record_arg(arg)
      if arg.persisted? && !arg.changed?
        process_active_record_arg_from_db(arg)
      else
        # @TODO Address this
        raise 'SidekiqArMiddleware can only handle persisted objects that have no changes right now - will change soon'
      end
    end

    def process_active_record_arg_from_db(arg)
      ActiveRecordWrapper.new(arg)
    end

  end
end
