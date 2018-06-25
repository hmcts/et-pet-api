module SidekiqArMiddleware
  class ActiveRecordWrapper
    def initialize(record)
      self.record = record
    end

    def to_json(*)
      if record.persisted? && record.changes.empty?
        {
            type: :sidekiq_ar_middleware_ar_wrapper,
            record_id: record.id,
            record_class_name: record.class.name
        }.to_json
      else
        raise 'Not yet supported - coming soon'
      end
    end

    private

    attr_accessor :record
  end
end
